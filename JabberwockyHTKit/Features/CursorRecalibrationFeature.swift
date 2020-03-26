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

@objc public class CursorRecalibrationFeature: NSObject, HTFeature {
    
    // MARK: Singleton Initialization
    @objc public private(set) static var shared: CursorRecalibrationFeature?
    
    override private init() { }
    
    @objc public static func configure(withFeatureEnabled enabled: Bool = true) -> HTFeature {
        if CursorRecalibrationFeature.shared == nil {
            CursorRecalibrationFeature.shared = CursorRecalibrationFeature()
            if enabled {
                CursorRecalibrationFeature.shared?.enable()
            }
        }
        return CursorRecalibrationFeature.shared!
    }
    
    // MARK: HeadTrackingFeature protocol
    @objc public private(set) var enabled = false
    
    @objc public func enable() {
        enabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.startRecalibrateCountdown),
                                               name: .htOnHeadShakeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.startRecalibrateCountdown),
                                               name: .htInitiateRecalibrationCountdownNotification, object: nil)
    }
    
    @objc public func disable() {
        enabled = false
        NotificationCenter.default.removeObserver(self, name: .htOnHeadShakeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .htInitiateRecalibrationCountdownNotification, object: nil)
    }
    
    // MARK: Internal
    private var recalibrating = false

    @objc private func startRecalibrateCountdown() {
        if !recalibrating {
            recalibrating = true
            HTCursor.shared.active = false
            CountdownView.shared.dismissStyle = .none
            CountdownView.show(countdownFrom: 3, spin: false, animation: .zoomIn, autoHide: true, completion: {
                HTCursor.shared.active = true
                self.recalibrating = false
                HeadTracking.shared.analytics.sendEvent(event: .Calibrate, additionalParameters: [:])
                HeadTracking.shared.recalibrateImmediately()
            })
        }
    }
}
