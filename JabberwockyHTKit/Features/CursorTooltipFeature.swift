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

@objc public class CursorTooltipFeature: NSObject, HTFeature {
    
    private let DELAY: CFTimeInterval = 1.5
    private let DECAY_FACTOR: Float = 3.0
    
    // MARK: Singleton Initialization
    @objc public private(set) static var shared: CursorTooltipFeature?
    
    override private init() {
        _tooltipChargingTimer = ChargingTimer(for: DELAY, cycle: false, decayFactor: DECAY_FACTOR)
    }
    
    @objc public static func configure(withFeatureEnabled enabled: Bool = true) -> HTFeature {
        if CursorTooltipFeature.shared == nil {
            CursorTooltipFeature.shared = CursorTooltipFeature()
            if enabled {
                CursorTooltipFeature.shared?.enable()
            }
        }
        return CursorTooltipFeature.shared!
    }
    
    // MARK: HTFeature protocol
    @objc public private(set) var enabled = false
    
    @objc public func enable() {
        enabled = true
        HTWindows.shared.enable(for: self, of: TooltipWindow.self)
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.onFocusNotification(_:)),
            name: .htOnCursorFocusUpdateNotification, object: nil)
    }
    
    @objc public func disable() {
        enabled = false
        HTWindows.shared.disable(for: self)
        NotificationCenter.default.removeObserver(self, name: .htOnCursorFocusUpdateNotification, object: nil)
    }

    // MARK: Internal
    private var _chargingFocusedElement: HTFocusable? = nil
    private var _tooltipChargingTimer: ChargingTimer
    
    @objc func onFocusNotification(_ notification: NSNotification)  {
        
        guard let tooltipWindow = HTWindows.shared.getWindow(for: self) as? TooltipWindow else {
            disposeOfChargingFacadeView(nil)
            return
        }
        
        guard HTCursor.shared.active else {
            disposeOfChargingFacadeView(tooltipWindow)
            return
        }
        
        guard let focusContext = notification.userInfo?[NSNotification.htFocusContextKey]
            as? HTFocusContext else {
                disposeOfChargingFacadeView(tooltipWindow)
                return
        }
     
        if _tooltipChargingTimer.charge == 0 {
            disposeOfChargingFacadeView(tooltipWindow)
            _chargingFocusedElement = focusContext.focusedElement
        }
        
        let secondsElapsed = focusContext.cursorContext.secondsSinceLastInstance
        _tooltipChargingTimer.update(secondsElapsed, increaseCondition: {
            return focusContext.focusedElement === self._chargingFocusedElement
        })
        
        if _tooltipChargingTimer.isFull, let tooltipText = focusContext.focusedElement.htTooltipText {
            tooltipWindow.tooltipView.showTooltip(tooltipText, focusContext.focusedElement)
        }

    }
    
    private func disposeOfChargingFacadeView(_ tooltipWindow: TooltipWindow?) {
        _tooltipChargingTimer.charge = 0
        if let chargingFocusedElement = _chargingFocusedElement {
            tooltipWindow?.tooltipView.hideTooltip(chargingFocusedElement)
        }
        _chargingFocusedElement = nil
    }
}
