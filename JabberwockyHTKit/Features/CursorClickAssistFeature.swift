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

@objc public class CursorClickAssistFeature: NSObject, HTFeature {
    
    // MARK: Public Fields
    /**
     The current focusable that is targeted by the cursor after  the minimum element size hit boxes are applied.
     This focusable gets updated during the cursor update process and may or may not be one notification behind
     for concurrent notification observer captures of .htOnCursorUpdateNotification...
     */
    @objc public static var currentFocusable: HTFocusable? {
        return shared?.focusedFacadeView?.focusableDelegate
    }
    
    // MARK: Singleton Initialization
    @objc public private(set) static var shared: CursorClickAssistFeature?
    
    override private init() {
        _focusableRefreshChargingTimer = ChargingTimer(for: 0.1, cycle: false, autoCharge: true)
    }
    
    @objc public static func configure(withFeatureEnabled enabled: Bool = true) -> HTFeature {
        if CursorClickAssistFeature.shared == nil {
            CursorClickAssistFeature.shared = CursorClickAssistFeature()
            if enabled {
                CursorClickAssistFeature.shared?.enable()
            }
        }
        return CursorClickAssistFeature.shared!
    }
    
    // MARK: HeadTrackingFeature protocol
    @objc public private(set) var enabled = false

    @objc public func enable() {
        enabled = true
        HTWindows.shared.enable(for: self, of: ClickAssistWindow.self)
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.onCursorUpdateNotification(_:)),
            name: .htOnCursorPreUpdateNotification, object: nil)
        // Need this one to make sure a nil update is faked after Head Tracking is disabled
        // Animations and focusable borders need to be cleaned up.
        NotificationCenter.default.addObserver(self,
            selector: #selector(self.onCursorUpdateNotification(_:)),
            name: .htOnHeadTrackingStatusUpdateNotification, object: nil)
    }
    
    @objc public func disable() {
        enabled = false
        HTWindows.shared.disable(for: self)
        NotificationCenter.default.removeObserver(
            self, name: .htOnCursorPreUpdateNotification, object: nil)
        NotificationCenter.default.removeObserver(
            self, name: .htOnHeadTrackingStatusUpdateNotification, object: nil)
    }
    
    // MARK: Focus Target
    private(set) var focusedFacadeView: FocusableFacadeView? = nil

    // MARK: Internal
    private var _focusableRefreshChargingTimer: ChargingTimer

    @objc func onCursorUpdateNotification(_ notification: NSNotification)  {
        
        guard let clickAssistWindow = HTWindows.shared.getWindow(for: self) as? ClickAssistWindow else {
            focusedFacadeView = nil
            return
        }

        guard let focusableGlassView = clickAssistWindow.focusableGlassView else {
            focusedFacadeView = nil
            return
        }
        
        guard HTCursor.shared.active else {
            cleanUp(focusableGlassView)
            return
        }
        
        guard let cursorContext = notification.userInfo?[NSNotification.htCursorContextKey] as? HTCursorContext else {
            cleanUp(focusableGlassView)
            return
        }

        guard let screenPoint = (cursorContext.smoothedScreenPoint.exists ? cursorContext.smoothedScreenPoint.point: nil) else {
            cleanUp(focusableGlassView)
            return
        }
        
        _focusableRefreshChargingTimer.consumeIfCharged {
            let focusableViews = HTFeatureUtils.getFocusableViews()
            focusableGlassView.collectFocusableViews(focusableViews)
        }
        self.focusedFacadeView = focusableGlassView.getFocusedFacadeView(at: screenPoint) ?? nil
        
        for focusableView in focusableGlassView.focusableViewMap.values {
            focusableView == focusedFacadeView ? focusableView.htFocus() : focusableView.htBlur()
        }
        
        //Send focus notification... currently only used by the KeyboardFeature
        DispatchQueue.main.async {
            if let focusedElement = self.focusedFacadeView?.focusableDelegate {
                NotificationCenter.default.post(
                    name: .htOnCursorFocusNotification, object: nil,
                    userInfo: [NSNotification.htCursorContextKey: cursorContext,
                               NSNotification.htFocusedElementKey: focusedElement])
            } else {
                NotificationCenter.default.post(
                    name: .htOnCursorFocusNotification, object: nil,
                    userInfo: [NSNotification.htCursorContextKey: cursorContext])
            }
        }
    }
    
    private func cleanUp(_ focusableGlassView: FocusableGlassView) {
        focusedFacadeView = nil
        focusableGlassView.focusableViewMap.values.forEach {
            $0.htBlur()
        }
    }
}
