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

@objc public class CursorBlinkClickFeature: NSObject, HTFeature {
    
    @objc public var clickAction: (CGPoint) -> Void {
        get {
            return _clickAction
        } set {
            _clickAction = newValue
        }
    }
    
    // MARK: Singleton Initialization
    @objc public private(set) static var shared: CursorBlinkClickFeature?

    override private init() { }

    @objc public static func configure(withFeatureEnabled enabled: Bool = true) -> HTFeature {
        if CursorBlinkClickFeature.shared == nil {
            CursorBlinkClickFeature.shared = CursorBlinkClickFeature()
            if enabled {
                CursorBlinkClickFeature.shared?.enable()
            }
        }
        return CursorBlinkClickFeature.shared!
    }

    // MARK: HTFeature protocol
    @objc public private(set) var enabled = false

    @objc public func enable() {
        enabled = true
        NotificationCenter.default.addObserver(
                self, selector: #selector(self.onBlinkNotification(_:)),
                name: .htOnBlinkNotification, object: nil)
    }

    @objc public func disable() {
        enabled = false
        NotificationCenter.default.removeObserver(
                self, name: .htOnCursorUpdateNotification, object: nil)
    }

    // MARK: Internal
    private var _clickAction: (CGPoint) -> Void = { screenPoint in
        guard let focusableFacade = CursorClickAssistFeature.shared?.focusedFacadeView else {
            return
        }
        focusableFacade.focusableDelegate.htInitiateAction(screenPoint)
    }
    
    @objc func onBlinkNotification(_ notification: NSNotification)  {
        guard let blinkContext = notification.userInfo?[NSNotification.htBlinkContextKey]
            as? HTBlinkContext else { return }
        
        guard HTCursor.shared.active else { return }
        
        guard HeadTracking.shared.settings.clickGesture == .Blink else { return }

        guard let focusableFacade = CursorClickAssistFeature.shared?.focusedFacadeView else { return }
        
        guard focusableFacade.focusableDelegate.htIgnoresCursorMode() ||
            HTCursor.shared.actualCursorMode.isClickMode else { return }
        
        guard focusableFacade.focusableDelegate.htIgnoresScrollSpeed() ||
            !CursorScrollFeature.isScrollingFast else { return }
        
        guard blinkContext.blinkDuration >= HTBlinkSensitivity.shared.durationSeconds else {
            focusableFacade.focusableDelegate.htHandleTooShortClick()
            return
        }
        
        let optionalScreenPoint = blinkContext.cursorContext.smoothedScreenPoint

        if let screenPoint = (optionalScreenPoint.exists ? optionalScreenPoint.point: nil) {
            focusableFacade.htAnimateClick()
            focusableFacade.htPlayClickSound()
            // Translate screen point touching a facade view to a screen point inside the facade's delegate.
            clickAction(focusableFacade.htTargetScreenPoint(screenPoint))
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .htOnCursorClickNotification, object: nil,
                    userInfo: [NSNotification.htFocusedElementKey: focusableFacade.focusableDelegate])
            }
        }
    }
}
