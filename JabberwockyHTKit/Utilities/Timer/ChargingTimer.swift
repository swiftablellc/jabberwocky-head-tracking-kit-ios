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

import Foundation

class ChargingTimer {

    private let AUTO_CHARGE_INTERVAL: TimeInterval = 0.01 // 1/100th of a second

    private(set) var duration: CFTimeInterval
    private(set) var increaseCondition: () -> Bool
    private(set) var completionClosure: () -> Void
    private(set) var deltaUpdateClosure: (Float, Float) -> Void

    private var _charge: Float = 0.0

    // Charge goes from 0.0 to 1.0
    var charge: Float {
        get { return _charge }
        set {
            _charge = max(0.0, min(1.0, newValue))
        }
    }

    var isFull: Bool { return charge == 1.0 }
    var enabled: Bool = true
    var cycle: Bool
    var decayFactor: Float

    init (for duration: CFTimeInterval, when increase: @escaping () -> Bool = {return true},
          doWhenFull completion: @escaping () -> Void = {},
          handleDelta deltaUpdate: @escaping (Float, Float) -> Void = {(_, _) in return},
          cycle: Bool = true, autoCharge: Bool = false, decayFactor: Float = 1.0) {
        self.duration = duration
        self.increaseCondition = increase
        self.completionClosure = completion
        self.deltaUpdateClosure = deltaUpdate
        self.cycle = cycle
        self.decayFactor = decayFactor
        self.charge = 0.0
        if autoCharge {
            Timer.scheduledTimer(timeInterval: AUTO_CHARGE_INTERVAL, target: self,
                    selector: #selector(autoUpdate), userInfo: nil, repeats: true)
        }
    }

    func consumeIfCharged(onConsume: @escaping () -> Void = {}) {
        if isFull {
            charge = 0.0
            onConsume()
        }
    }

    @objc internal func autoUpdate() {
        update(AUTO_CHARGE_INTERVAL)
    }

    func update(_ secondsElapsed: CFTimeInterval) {
        update(secondsElapsed, increaseCondition: increaseCondition)
    }

    func update(_ secondsElapsed: CFTimeInterval, increaseCondition: @escaping () -> Bool) {
        if enabled {
            let delta = Float(secondsElapsed / duration)
            let previousCharge = charge
            charge += increaseCondition() ? delta : -(delta * decayFactor)
            deltaUpdateClosure(previousCharge, charge)
            if charge == 1.0 && previousCharge < 1.0 {
                completionClosure()
                if cycle {
                    charge = 0.0
                }
            }
        }
    }
}
