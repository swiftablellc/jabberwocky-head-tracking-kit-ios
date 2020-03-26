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

@objc public class CursorIdleFeature: NSObject, HTFeature {
    
    private let ACTIVE_TIME_SECONDS: CFTimeInterval = 0.5
    private let IDLE_TIME_SECONDS: CFTimeInterval = 20.0
    private let ACTIVE_TO_IDLE_FACTOR: Float = 5.0
    private let RECENTLY_IDLE_TIME_SECONDS: CFTimeInterval = 2.0

    // MARK: Singleton Initialization
    @objc public private(set) static var shared: CursorIdleFeature?
    
    override private init() { }

    @objc public static func configure(withFeatureEnabled enabled: Bool = true) -> HTFeature {
        if CursorIdleFeature.shared == nil {
            CursorIdleFeature.shared = CursorIdleFeature()
            if enabled {
                CursorIdleFeature.shared?.enable()
            }
        }
        return CursorIdleFeature.shared!
    }
    
    @objc public static var isIdle: Bool {
        return (idleTransitionLevel == 1.0)
    }
    
    @objc public static var isFullyActive: Bool {
        return (idleTransitionLevel == 0.0)
    }
    
    @objc public static var idleTransitionLevel: Float {
        guard let shared = CursorIdleFeature.shared, let timer = shared.idleChargingTimer else {
                return 0.0
        }
        
        if timer.isFull {
            return 1.0
        }
        
        let charge = timer.charge
        let idleTransitionTime = Float(shared.ACTIVE_TIME_SECONDS) *
            shared.ACTIVE_TO_IDLE_FACTOR
        let minimumTransitionThreshold =
            1 - (idleTransitionTime / Float(shared.IDLE_TIME_SECONDS))
        if charge < minimumTransitionThreshold {
            return 0.0
        }
        
        return (charge - minimumTransitionThreshold) / (1 - minimumTransitionThreshold)
    }
    
    private var idleChargingTimer: ChargingTimer?
    private var lastIdleTime: CFTimeInterval?

    // MARK: HeadTrackingFeature protocol
    @objc public private(set) var enabled = false

    @objc public func enable() {
        enabled = true
        idleChargingTimer = ChargingTimer(
            for: IDLE_TIME_SECONDS, cycle: false,
            decayFactor: ACTIVE_TO_IDLE_FACTOR)
        idleChargingTimer?.enabled = false
        NotificationCenter.default.addObserver(
                self, selector: #selector(onCursorUpdateNotification(_:)),
                name: .htOnCursorUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(onCursorClickNotification),
            name: .htOnCursorClickNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(onRecalibrateNotification),
            name: .htOnRecalibrateNotification, object: nil)
    }

    @objc public func disable() {
        enabled = false
        idleChargingTimer = nil
        NotificationCenter.default.removeObserver(
                self, name: .htOnCursorUpdateNotification, object: nil)
        NotificationCenter.default.removeObserver(
            self, name: .htOnCursorClickNotification, object: nil)
        NotificationCenter.default.removeObserver(
            self, name: .htOnRecalibrateNotification, object: nil)
    }

    // MARK: Internal
    @objc func onCursorUpdateNotification(_ notification: NSNotification)  {
        guard let cursorContext = notification.userInfo?[NSNotification.htCursorContextKey]
            as? HTCursorContext else {
            return
        }
        
        idleChargingTimer?.enabled = true
        idleChargingTimer?.update(cursorContext.secondsSinceLastInstance, increaseCondition: {
            return !cursorContext.isMovingFast
        })
        if CursorIdleFeature.isIdle {
            lastIdleTime = CACurrentMediaTime()
        }
        //Reset idle timer if we go from fully idle to fully active in a short time
        if CursorIdleFeature.isFullyActive {
            let now = CACurrentMediaTime()
            if let lastIdleTime = self.lastIdleTime {
                if now - lastIdleTime < RECENTLY_IDLE_TIME_SECONDS {
                    idleChargingTimer?.charge = 0
                }
            }
        }
    }
    
    @objc func onCursorClickNotification() {
        //Clicks reset idle
        idleChargingTimer?.charge = 0
    }
    
    @objc func onRecalibrateNotification() {
        //Recalibrate resets idle
        idleChargingTimer?.charge = 0
    }
}
