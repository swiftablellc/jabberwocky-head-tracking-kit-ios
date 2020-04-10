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

import UIKit

class TooltipGlassView: HTGlassView {
    
    private static let smallFont: UIFont = {
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return UIFont.systemFont(ofSize: 16)
        case .pad:
            return UIFont.systemFont(ofSize: 24)
        default:
            return UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        }
    }()
    
    private let PAD_TOOLTIP_WIDTH: CGFloat = 300
    private let PHONE_TOOLTIP_WIDTH: CGFloat = 240
    private let PAD_TOOLTIP_HEIGHT: CGFloat = 60
    private let PHONE_TOOLTIP_HEIGHT: CGFloat = 50
    
    private var tooltipLabel: UIView?
    private weak var focusableWithTooltip: HTFocusable?
    
    required init(coder decoder: NSCoder) {
        fatalError(" does not support NSCoding (Serialization)...")
    }
    
    init() {
        super.init(frame: CGRect.zero)
        NotificationCenter.default.addObserver(self, selector: #selector(checkForOrphanedTooltip),
            name: .htOnCursorUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkForOrphanedTooltip),
            name: .htOnHeadTrackingStatusUpdateNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .htOnCursorUpdateNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .htOnHeadTrackingStatusUpdateNotification, object: nil)
    }

    func showTooltip(_ tooltip: String, _ focusable: HTFocusable) {
        //One tooltip at a time
        if tooltipLabel != nil {
            tooltipLabel?.removeFromSuperview()
            tooltipLabel = nil
        }
    
        focusableWithTooltip = focusable
        
        let newTooltipLabel = constructTooltipView(tooltip)
        self.tooltipLabel = newTooltipLabel
        self.addSubview(newTooltipLabel)
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let tooltipWidth: CGFloat = isPad ? PAD_TOOLTIP_WIDTH : PHONE_TOOLTIP_WIDTH
        let tooltipHeight: CGFloat = isPad ? PAD_TOOLTIP_HEIGHT: PHONE_TOOLTIP_HEIGHT
        let tooltipFrameInWindow: CGRect = {
            let viewFrameInWindow = focusable.htFrameInScreenCoordinates()
            
            let centerX = viewFrameInWindow.midX
            let tooltipLeft = min(max(HTLayout.largePadding, centerX - tooltipWidth / 2),
                                  UIScreen.main.bounds.width - tooltipWidth - HTLayout.largePadding)
            
            let showAboveView = viewFrameInWindow.midY > UIScreen.main.bounds.height / 2
            let tooltipTop = showAboveView ?
                (viewFrameInWindow.minY - tooltipHeight - HTLayout.defaultPadding) :
                (viewFrameInWindow.maxY + HTLayout.defaultPadding)
            
            return CGRect(x: tooltipLeft, y: tooltipTop, width: tooltipWidth, height: tooltipHeight)
        }()
    
        let tooltipFrameInGlassView = self.convert(tooltipFrameInWindow, from: nil)
        newTooltipLabel.frame = tooltipFrameInGlassView
    }
    
    func hideTooltip(_ focusable: HTFocusable) {
        if focusable !== self.focusableWithTooltip {
            return
        }
        
        tooltipLabel?.removeFromSuperview()
        tooltipLabel = nil
        focusableWithTooltip = nil
    }
    
    @objc private func checkForOrphanedTooltip() {
        if self.focusableWithTooltip !== nil {
            return
        }
        
        tooltipLabel?.removeFromSuperview()
        tooltipLabel = nil
    }
    
    private func constructTooltipView(_ tooltip: String) -> UIView {
        let label = UILabel()
        
        label.font = TooltipGlassView.smallFont
        label.textAlignment = .center
        label.textColor = ThemeColors.primaryText
        label.text = tooltip
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        
        let view = UIView()
        view.backgroundColor = ThemeColors.standardBackground
        
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 10.0
        
        //TODO corners don't work without maskToBounds, which ruins shadow. Need to use multiple
        //layers or views or something.
        
        view.addSubview(label)
        
        let textBuffer: CGFloat = 10
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: textBuffer).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -textBuffer).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: textBuffer).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -textBuffer).isActive = true
        
        return view
    }
}
