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
        HTWindows.shared.enable(for: self, of: CursorEffectsWindow.self)
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.onCursorUpdateNotification(_:)),
            name: .htOnCursorUpdateNotification, object: nil)
    }
    
    @objc public func disable() {
        enabled = false
        HTWindows.shared.disable(for: self)
        NotificationCenter.default.removeObserver(
            self, name: .htOnCursorUpdateNotification, object: nil)
    }

    // MARK: Internal
    private var _chargingFacadeView: FocusableFacadeView? = nil
    private var _tooltipChargingTimer: ChargingTimer
    
    @objc func onCursorUpdateNotification(_ notification: NSNotification)  {
        
        guard let tooltipWindow = HTWindows.shared.getWindow(for: self) as? CursorEffectsWindow else {
            disposeOfChargingFacadeView(nil)
            return
        }
        
        guard HTCursor.shared.active else {
            disposeOfChargingFacadeView(tooltipWindow)
            return
        }
        
        guard let cursorContext = notification.userInfo?[NSNotification.htCursorContextKey]
            as? HTCursorContext else {
                disposeOfChargingFacadeView(tooltipWindow)
                return
        }
        if let facadeView = CursorClickAssistFeature.shared?.focusedFacadeView {
            
            if _tooltipChargingTimer.charge == 0 {
                disposeOfChargingFacadeView(tooltipWindow)
                _chargingFacadeView = facadeView
            }
            
            let secondsElapsed = cursorContext.secondsSinceLastInstance
            _tooltipChargingTimer.update(secondsElapsed, increaseCondition: {
                return facadeView == self._chargingFacadeView
            })
            
            if _tooltipChargingTimer.isFull, let tooltipText = facadeView.focusableDelegate.htTooltipText {
                tooltipWindow.showTooltip(tooltipText, facadeView)
            }
        } else {
            disposeOfChargingFacadeView(tooltipWindow)
        }

    }
    
    private func disposeOfChargingFacadeView(_ tooltipWindow: CursorEffectsWindow?) {
        _tooltipChargingTimer.charge = 0
        if let chargingView = _chargingFacadeView {
            tooltipWindow?.hideTooltip(chargingView)
        }
        _chargingFacadeView = nil
    }
}
