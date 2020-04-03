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

@objc public class CursorDwellClickFeature: NSObject, HTFeature {
    
    @objc public var clickAction: (CGPoint) -> Void {
        get {
            return _clickAction
        } set {
            _clickAction = newValue
        }
    }
    
    // MARK: Singleton Initialization
    @objc public private(set) static var shared: CursorDwellClickFeature?

    override private init() { }

    @objc public static func configure(withFeatureEnabled enabled: Bool = true) -> HTFeature {
        if CursorDwellClickFeature.shared == nil {
            CursorDwellClickFeature.shared = CursorDwellClickFeature()
            if enabled {
                CursorDwellClickFeature.shared?.enable()
            }
        }
        return CursorDwellClickFeature.shared!
    }

    // MARK: HTFeature protocol
    @objc public private(set) var enabled = false

    @objc public func enable() {
        enabled = true
        NotificationCenter.default.addObserver(
                self, selector: #selector(self.onCursorUpdateNotification(_:)),
                name: .htOnCursorUpdateNotification, object: nil)
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
    
    @objc func onCursorUpdateNotification(_ notification: NSNotification)  {
        guard let cursorContext = notification.userInfo?[NSNotification.htCursorContextKey]
            as? HTCursorContext else {
            return
        }
        
        guard HTCursor.shared.active else { return }

        guard HeadTracking.shared.settings.clickGesture == .Dwell else { return }

        guard let focusableFacade = CursorClickAssistFeature.shared?.focusedFacadeView else { return }

        guard focusableFacade.focusableDelegate.htIgnoresCursorMode() ||
           HTCursor.shared.actualCursorMode.isClickMode else { return }

        guard focusableFacade.focusableDelegate.htIgnoresScrollSpeed() ||
           !CursorScrollFeature.isScrollingFast else { return }
        
        // Fully focused facade indicates that the configured dwell time has completed
        guard focusableFacade.isFullyFocused else { return }

        let optionalScreenPoint = cursorContext.smoothedScreenPoint
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
