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

internal let kPulsatorAnimationKey = "pulsator"

@objc public class Pulsator: CALayer {

    fileprivate var chargingTimer: ChargingTimer!
    fileprivate var animationDuration: TimeInterval!

    /// The value of this property showed a pulse is ongoing
    @objc open var isPulsating: Bool {
        return (sublayers?.count ?? 0) > 0
    }

    @objc public init(numPulse: Double = 1.0, animationDuration: TimeInterval = 1.0) {
        super.init()
        self.animationDuration = animationDuration
        let timerDuration: TimeInterval
        if numPulse > 0 {
            timerDuration = animationDuration / TimeInterval(numPulse)
        } else {
            timerDuration = animationDuration
        }
        chargingTimer = ChargingTimer(for: timerDuration, cycle: false, autoCharge: true)
    }

    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func pulseIfCharged() {
        chargingTimer.consumeIfCharged(onConsume: {
            let pulse = PulseAnimationLayer(animationDuration: self.animationDuration)
            self.addSublayer(pulse)
        })
    }

    class PulseAnimationLayer: CALayer, CAAnimationDelegate {
        fileprivate var animationDuration: TimeInterval!
        fileprivate var animationGroup: CAAnimationGroup!
        fileprivate var radius: CGFloat = 75
        fileprivate var alpha = 0.5

        // MARK: - Initializer
        public init(animationDuration: TimeInterval) {
            super.init()
            self.animationDuration = animationDuration
            setupPulse()
            setupAnimationGroup()
            add(animationGroup, forKey: kPulsatorAnimationKey)
        }

        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        fileprivate func setupPulse() {
            backgroundColor = ThemeColors.darkishPurple.cgColor
            contentsScale = UIScreen.main.scale
            opacity = 0
            bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: radius * 2, height: radius * 2))
            cornerRadius = radius
            backgroundColor = backgroundColor
        }

        fileprivate func setupAnimationGroup() {
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
            scaleAnimation.fromValue = 1.0
            scaleAnimation.toValue = 0.0
            scaleAnimation.duration = animationDuration

            let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnimation.duration = animationDuration
            opacityAnimation.values = [0.0, 0.5 * alpha, alpha]
            opacityAnimation.keyTimes = [0.0, 0.85, 1.0]

            animationGroup = CAAnimationGroup()
            animationGroup.animations = [scaleAnimation, opacityAnimation]
            animationGroup.duration = animationDuration
            animationGroup.delegate = self
        }

        // MARK: - Delegate methods for CAAnimation
        public func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
            removeFromSuperlayer()
        }
    }
}
