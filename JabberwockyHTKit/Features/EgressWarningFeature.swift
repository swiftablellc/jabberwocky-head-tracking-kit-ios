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

@objc public class EgressWarningFeature: NSObject, HTFeature {
    
    private static let DEFAULT_EGRESS_MESSAGE = "WARNING: This action will take you outside of " + "\(HeadTracking.shared.settings.appName). " +
        "You will not be able to use the head cursor."

    // MARK: Singleton Initialization
    @objc public private(set) static var shared: EgressWarningFeature?
    
    override private init() { }
    
    @objc public static func configure(withFeatureEnabled enabled: Bool = true) -> HTFeature {
        if EgressWarningFeature.shared == nil {
            EgressWarningFeature.shared = EgressWarningFeature()
            if enabled {
                EgressWarningFeature.shared?.enable()
            }
        }
        return EgressWarningFeature.shared!
    }
    
    // MARK: HTFeature protocol
    @objc public private(set) var enabled = false
    
    @objc public func enable() {
        enabled = true
    }
    
    @objc public func disable() {
        enabled = false
    }
    
    // MARK: Public Fields
    @objc public var egressMessage = EgressWarningFeature.DEFAULT_EGRESS_MESSAGE
    
    // MARK: Egress
    @objc public static func guardEgress(_ title: String,
                                   completion: @escaping () -> Void,
                                   cancelCompletion: @escaping () -> Void = {}) {
        
        guard let feature = EgressWarningFeature.shared else {
            completion()
            return
        }

        guard HeadTracking.shared.isEnabled && feature.enabled else {
            completion()
            return
        }
        
        guard let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else {
            completion()
            return
        }
        
        let alertController = HTAlertController(title: title, message: feature.egressMessage)
        alertController.addAction(HTAlertAction(title: "Cancel", style: .bold, action: {
            cancelCompletion()
            alertController.dismiss(animated: false)
        }))
        alertController.addAction(HTAlertAction(title: "Continue", action: {
            completion()
            alertController.dismiss(animated: false)
        }))
        navigationController.present(alertController, animated: false)
    }
    
}
