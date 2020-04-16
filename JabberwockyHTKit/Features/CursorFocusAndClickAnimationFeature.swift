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

import JabberwockyHTKitCore
import UIKit

@objc public class CursorFocusAndClickAnimationFeature: NSObject, HTFeature {
    
    // MARK: Singleton Initialization
    @objc public private(set) static var shared: CursorFocusAndClickAnimationFeature?

    override private init() { }

    @objc public static func configure() -> HTFeature {
        if CursorFocusAndClickAnimationFeature.shared == nil {
            CursorFocusAndClickAnimationFeature.shared = CursorFocusAndClickAnimationFeature()
        }
        return CursorFocusAndClickAnimationFeature.shared!
    }

    // MARK: HTFeature protocol
    @objc public private(set) var enabled = false

    @objc public func enable() {
        enabled = true
        HTWindows.shared.enable(for: self, of: FocusAndClickAnimationWindow.self)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.onClickNotification(_:)),
            name: .htOnCursorClickNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.onFocusNotification(_:)),
            name: .htOnCursorFocusUpdateNotification, object: nil)
        // Animations and focusable borders need to be cleaned up.
        NotificationCenter.default.addObserver(self,
            selector: #selector(self.onFocusNotification(_:)),
            name: .htOnHeadTrackingStatusUpdateNotification, object: nil)
    }

    @objc public func disable() {
        enabled = false
        HTWindows.shared.disable(for: self)
        NotificationCenter.default.removeObserver(self, name: .htOnCursorClickNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .htOnCursorFocusUpdateNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .htOnHeadTrackingStatusUpdateNotification, object: nil)
    }

    // MARK: Internal
    
    private let START_ALPHA: CGFloat = 0.1
    private let END_ALPHA: CGFloat = 1.0
    
    private static let CORNER_RADIUS: CGFloat = 15.0
    private static let BORDER_WIDTH: CGFloat = 3.0
    private static let VIEWING_RECT_SPACING: CGFloat = 3.0
    //This will make viewing rectangles look nice by having some space between them and the element
    private static let VIEWING_RECT_FUDGE_FACTOR: CGFloat = 2 * ((1 - 0.707) * (CORNER_RADIUS + BORDER_WIDTH) + VIEWING_RECT_SPACING)
    
    private var focusAnimationView = UIView()
    private var currentClickAnimationCount = AtomicPositiveInteger()

    @objc private func onClickNotification(_ notification: NSNotification) {

        guard let focusContext = notification.userInfo?[NSNotification.htFocusContextKey] as? HTFocusContext else {
            return
        }
        
        guard let glassView = (HTWindows.shared.getWindow(for: self) as? FocusAndClickAnimationWindow)?.glassView else {
            return
        }
        
        let animationViewFrame = calculateTargetAnimationFrame(from: focusContext.focusRect)
        let clickAnimationView = UIView(frame: animationViewFrame)
        clickAnimationView.backgroundColor = UIColor.clear
        clickAnimationView.layer.cornerRadius = CursorFocusAndClickAnimationFeature.CORNER_RADIUS
        clickAnimationView.layer.borderWidth = CursorFocusAndClickAnimationFeature.BORDER_WIDTH
        clickAnimationView.layer.borderColor = ThemeColors.highlight.cgColor
        glassView.addSubview(clickAnimationView)
        
        self.currentClickAnimationCount.incrementAndGet()
        ClickAnimator.shared.execute(on: clickAnimationView, completion: {
            self.currentClickAnimationCount.decrementAndGet()
            clickAnimationView.removeFromSuperview()
        })
    }
    
    @objc private func onFocusNotification(_ notification: NSNotification) {
        
        guard let focusContext = notification.userInfo?[NSNotification.htFocusContextKey] as? HTFocusContext else {
            focusAnimationView.removeFromSuperview()
            return
        }
        
        guard let glassView = (HTWindows.shared.getWindow(for: self) as? FocusAndClickAnimationWindow)?.glassView else {
            focusAnimationView.removeFromSuperview()
            return
        }
        
        guard self.currentClickAnimationCount.value == 0 else {
            focusAnimationView.removeFromSuperview()
            return
        }
        
        if !glassView.subviews.contains(focusAnimationView) {
            glassView.addSubview(focusAnimationView)
        }
        
        let originFrame = focusContext.focusedElement.htFrameInScreenCoordinates()
        let targetFrame = calculateTargetAnimationFrame(from: focusContext.focusRect)
        let focusLevel = focusContext.focusedElement.htFocusLevel
        focusAnimationView.frame = calculateFocusAnimationFrame(originFrame, targetFrame, focusLevel)
        focusAnimationView.backgroundColor = UIColor.clear
        focusAnimationView.layer.cornerRadius = CursorFocusAndClickAnimationFeature.CORNER_RADIUS
        focusAnimationView.layer.borderWidth = CursorFocusAndClickAnimationFeature.BORDER_WIDTH
        focusAnimationView.layer.borderColor = ThemeColors.highlight.cgColor
        
        focusAnimationView.alpha = START_ALPHA + (END_ALPHA - START_ALPHA) * CGFloat(focusLevel)

    }
    
    private func calculateFocusAnimationFrame(_ start: CGRect, _ end: CGRect, _ focusLevel: Float) -> CGRect {
        let center = CGPoint(x: start.origin.x + start.width / 2, y: start.origin.y + start.height / 2)
        let height = start.height + ((end.height - start.height) * CGFloat(focusLevel))
        let width = start.width + ((end.width - start.width) * CGFloat(focusLevel))
        let x = center.x - width / 2
        let y = center.y - height / 2
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func calculateTargetAnimationFrame(from frame: CGRect) -> CGRect {
        let center = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height / 2)
        let height = frame.height + CursorFocusAndClickAnimationFeature.VIEWING_RECT_FUDGE_FACTOR
        let width = frame.width + CursorFocusAndClickAnimationFeature.VIEWING_RECT_FUDGE_FACTOR
        let x = center.x - width / 2
        let y = center.y - height / 2
        return CGRect(x: x, y: y, width: width, height: height)
    }

}
