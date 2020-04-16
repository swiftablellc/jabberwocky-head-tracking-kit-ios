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

@objc public class CursorFocusFeature: NSObject, HTFeature {
    
    private static let DEFAULT_FOCUS_DURATION: CFTimeInterval = 0.5

    // MARK: Singleton Initialization
    @objc public private(set) static var shared: CursorFocusFeature?
    
    override private init() {
        _focusableRefreshChargingTimer = ChargingTimer(for: 0.1, cycle: false, autoCharge: true)
    }
    
    @objc public static func configure() -> HTFeature {
        if CursorFocusFeature.shared == nil {
            CursorFocusFeature.shared = CursorFocusFeature()
        }
        return CursorFocusFeature.shared!
    }
    
    // MARK: HTFeature protocol
    @objc public private(set) var enabled = false

    @objc public func enable() {
        enabled = true
        HTWindows.shared.enable(for: self, of: CursorFocusWindow.self)
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.onCursorUpdateNotification(_:)),
            name: .htOnCursorUpdateNotification, object: nil)
        // Focus Levels need to be cleaned up
        NotificationCenter.default.addObserver(self,
            selector: #selector(self.onStatusUpdateNotification(_:)),
            name: .htOnHeadTrackingStatusUpdateNotification, object: nil)
    }
    
    @objc public func disable() {
        enabled = false
        resetAllFocusLevels()
        HTWindows.shared.disable(for: self)
        NotificationCenter.default.removeObserver(
            self, name: .htOnCursorUpdateNotification, object: nil)
        NotificationCenter.default.removeObserver(
            self, name: .htOnHeadTrackingStatusUpdateNotification, object: nil)
    }
    
    // MARK: Internal
    private var _focusableRefreshChargingTimer: ChargingTimer
    
    @objc func onStatusUpdateNotification(_ notification: NSNotification) {
        if !HeadTracking.shared.isEnabled {
            resetAllFocusLevels()
        }
    }

    @objc func onCursorUpdateNotification(_ notification: NSNotification) {
        
        guard let cursorContext = notification.userInfo?[NSNotification.htCursorContextKey] as? HTCursorContext else {
            return
        }
        
        guard let cursorFocusWindow = HTWindows.shared.getWindow(for: self) as? CursorFocusWindow else {
            sendFocusUpdateEventWithNoFocus(cursorContext)
            return
        }

        guard let focusableGlassView = cursorFocusWindow.focusableGlassView as? FocusableGlassView else {
            sendFocusUpdateEventWithNoFocus(cursorContext)
            return
        }
        
        guard HTCursor.shared.active else {
            sendFocusUpdateEventWithNoFocus(cursorContext)
            return
        }

        guard let screenPoint = (cursorContext.smoothedScreenPoint.exists ? cursorContext.smoothedScreenPoint.point: nil) else {
            sendFocusUpdateEventWithNoFocus(cursorContext)
            return
        }
        
        _focusableRefreshChargingTimer.consumeIfCharged {
            let focusableViews = HTFeatureUtils.getFocusableViews()
            focusableGlassView.collectFocusableViews(focusableViews)
        }

        let focusedFacadeView = focusableGlassView.getFocusedFacadeView(at: screenPoint) ?? nil
        
        guard let focusedElement = focusedFacadeView?.focusableDelegate else {
            sendFocusUpdateEventWithNoFocus(cursorContext)
            return
        }

        updateFocusLevels(focusedElement, secondsElapsed: cursorContext.secondsSinceLastInstance)
        
        DispatchQueue.main.async {
            let screenPointInElement = focusedFacadeView!.screenPointInTargetFrame(screenPoint)
            let focusRect = focusedFacadeView!.frame
            let focusContext = HTFocusContext(cursorContext, focusedElement, focusRect, screenPointInElement)
            NotificationCenter.default.post(
                name: .htOnCursorFocusUpdateNotification, object: nil,
                userInfo: [NSNotification.htFocusContextKey: focusContext])
        }

    }
    
    private func sendFocusUpdateEventWithNoFocus(_ cursorContext: HTCursorContext) {
        self.updateFocusLevels(secondsElapsed: cursorContext.secondsSinceLastInstance)
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .htOnCursorFocusUpdateNotification, object: nil,
                userInfo: [NSNotification.htCursorContextKey: cursorContext])
        }
    }
    
    private func resetAllFocusLevels() {
        // Default options for updateFocusLevels should always set all focusables htFocusLevel to 0.0
        updateFocusLevels()
    }
    
    private func updateFocusLevels(_ focusedElement: HTFocusable? = nil, secondsElapsed: CFTimeInterval? = nil) {
        
        guard let cursorFocusWindow = HTWindows.shared.getWindow(for: self) as? CursorFocusWindow else {
            return
        }

        guard let focusableGlassView = cursorFocusWindow.focusableGlassView as? FocusableGlassView else {
            return
        }
        
        focusableGlassView.getFocusableElements().forEach {
            if let secondsElapsed = secondsElapsed {
                let isFocused = focusedElement === $0
                let isDwellClick = HeadTracking.shared.settings.clickGesture == .Dwell
                let focusDuration = isDwellClick ? HTDwellTime.shared.durationSeconds : CursorFocusFeature.DEFAULT_FOCUS_DURATION
                let delta = secondsElapsed / focusDuration
                $0.htFocusLevel += Float(isFocused ? delta : -delta)
            } else {
                $0.htFocusLevel = 0.0
            }
        }
    }

}
