/*
Copyright 2020 Swiftable, LLC. <contact@swiftable.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import JabberwockyHTKitEngine
import UIKit.UIView

class CursorToggleView: UIView {
    private let TIME_TO_SHOW_TOGGLE_MENU_SECONDS: Double = 0.5
    
    private var buttons = [CursorToggleButton]()
    
    private var chargingTimer: ChargingTimer!
    private var animator: TransformAnimator!
    
    private let CLICK_ENABLED_IMAGE = "clickCentered"
    private let CLICK_DISABLED_IMAGE = "disabledClickCentered"
    private let SCROLL_ENABLED_IMAGE = "scroll"
    private let SCROLL_DISABLED_IMAGE = "disabledScroll"
    
    init() {
        super.init(frame: CGRect.zero)
        
        self.isHidden = true
        
        var toggleButtonSize = HTLayout.shorterDimension * 0.2
        var innerViewHeight = HTLayout.shorterDimension * 0.6
        var innerViewOffset: CGFloat = 0
        HTLayout.special([.portraitPhone, .landscapePhone]) {
            toggleButtonSize = HTLayout.shorterDimension * 0.3
            innerViewHeight = HTLayout.shorterDimension * 0.8
            innerViewOffset = -20
        }
        
        let innerView = UIView()
        self.addSubview(innerView)
        
        let clickButton = CursorToggleButton(.click, title: "Click",
                                             imageName: "clickCentered")
        buttons.append(clickButton)
        innerView.addSubview(clickButton)
        
        let scrollButton = CursorToggleButton(.scroll, title: "Scroll",
                                              imageName: "scroll")
        buttons.append(scrollButton)
        innerView.addSubview(scrollButton)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalTo: innerView.widthAnchor).isActive = true
        
        innerView.translatesAutoresizingMaskIntoConstraints = false
        innerView.heightAnchor.constraint(equalToConstant: innerViewHeight).isActive = true
        innerView.widthAnchor.constraint(equalTo: buttons[0].widthAnchor).isActive = true
        innerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        innerView.centerYAnchor.constraint(equalTo: self.centerYAnchor,
                                           constant: innerViewOffset).isActive = true
        
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: toggleButtonSize).isActive = true
            button.widthAnchor.constraint(equalToConstant: toggleButtonSize).isActive = true
            button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        }
        
        buttons[0].centerXAnchor.constraint(equalTo: innerView.centerXAnchor).isActive = true
        buttons[0].topAnchor.constraint(equalTo: innerView.topAnchor).isActive = true
        
        buttons[1].centerXAnchor.constraint(equalTo: innerView.centerXAnchor).isActive = true
        buttons[1].bottomAnchor.constraint(equalTo: innerView.bottomAnchor).isActive = true
        
        self.animator = TransformAnimator(self, failMode: .ignore, startTransformFunction: {
            [weak self] in
            
            guard let strongSelf = self else {
                return CGAffineTransform.identity
            }
            
            let width = strongSelf.frame.width
            let translate = CGAffineTransform(translationX: -width, y: 0)
            return translate
        })
        
        self.chargingTimer = ChargingTimer(
            for: TIME_TO_SHOW_TOGGLE_MENU_SECONDS,
            doWhenFull: {
                [weak self] in
                self?.animator.show()
            },
            handleDelta: {
                [weak self] (_, charge: Float) in
                
                if charge == 0 {
                    self?.animator.hide()
                }
            },
            cycle: false
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.onCursorUpdateNotification(_:)),
            name: .htOnCursorUpdateNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.onCursorModeUpdateNotification(_:)),
            name: .htOnCursorModeUpdateNotification, object: nil)
        
        updateButtons(HTCursor.shared.actualCursorMode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self, name: .htOnCursorUpdateNotification, object: nil)
        NotificationCenter.default.removeObserver(
            self, name: .htOnCursorModeUpdateNotification, object: nil)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitElement = super.hitTest(point, with: event)
        
        //Ignore focus events that hit this view and not its buttons
        //This way, we can focus and click underneath this view, like our browser bar
        if let _ = event as? SynthFocusHitTestEvent, hitElement == self {
            return nil
        }
        
        return hitElement
    }
    
    @objc func onCursorUpdateNotification(_ notification: NSNotification) {
        if let cursorContext = notification.userInfo?[NSNotification.htCursorContextKey] as? HTCursorContext {
            updateChargingTimer(cursorContext)
        }
    }
    
    @objc func onCursorModeUpdateNotification(_ notification: NSNotification) {
        if let cursorMode = notification.userInfo?[NSNotification.htCursorModeKey] as? CursorMode {
            updateButtons(cursorMode)
        }
    }
    
    private func updateChargingTimer(_ cursorContext: HTCursorContext) {
        self.chargingTimer.update(cursorContext.secondsSinceLastInstance, increaseCondition: {
            guard HTCursor.shared.active else { return false }
            guard !HTKeyboard.shared.isVisible else { return false }
            
            let onLeftEdge = cursorContext.onEdges.contains(.left)
            
            let onView: Bool = {
                guard let screenPoint = cursorContext.isFaceDetected ? cursorContext.smoothedScreenPoint : nil else {
                    return false
                }
                
                if self.isHidden { return false }
                
                let viewPoint = self.convert(screenPoint, from: nil)
                return self.point(inside: viewPoint, with: nil)
            }()
            
            return onLeftEdge || onView
        })
    }
    
    private func updateButtons(_ cursorMode: CursorMode) {
        for button in buttons {
            if let buttonId = button.currentTitle {
                var newTitle = ""
                var newImage = ""
                switch(buttonId) {
                case CursorToggle.click.rawValue:
                    newTitle = cursorMode.isClickMode ?
                        "Click\nEnabled" : "Click\nDisabled"
                    newImage = cursorMode.isClickMode ?
                        CLICK_ENABLED_IMAGE : CLICK_DISABLED_IMAGE
                case CursorToggle.scroll.rawValue:
                    newTitle = cursorMode.isScrollMode ?
                        "Scroll\nEnabled" : "Scroll\nDisabled"
                    newImage = cursorMode.isScrollMode ?
                        SCROLL_ENABLED_IMAGE : SCROLL_DISABLED_IMAGE
                default:
                    break
                }
                button.label.text = newTitle
                let cursorImage = UIImage(named: newImage, in: HeadTracking.FRAMEWORK_BUNDLE, compatibleWith: nil)
                button.setImage(cursorImage, for: .normal)
            }
        }
    }
    
    @objc func buttonClicked(_ button: UIButton) {
        guard let buttonId = button.currentTitle else {
            return
        }
        
        switch(buttonId) {
        case CursorToggle.click.rawValue:
            HTCursor.shared.toggleCursorMode(.click)
        case CursorToggle.scroll.rawValue:
            HTCursor.shared.toggleCursorMode(.scroll)
        default:
            break
        }
    }
}
