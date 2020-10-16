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

import UIKit.UIWindowScene

@objc public class HeadTracking: NSObject {
    
    // MARK: Framework Bundle
    internal static let FRAMEWORK_BUNDLE = Bundle(for: HeadTracking.self)

    // MARK: INFO and WARNINGs
    private static let CONFIGURED_SUCCESSFULLY = "Head Tracking configured successfully."
    private static let ENABLED_SUCCESSFULLY = "Head Tracking enabled successfully."
    private static let DISABLED = "Head Tracking disabled."
    private static let DISABLED_IN_SETTINGS = "Head Tracking was not enabled because it was disabled " +
            "in settings. It must be enabled through 'HeadTracking.shared.settings.disabledByUser = false'."
    private static let NOT_CONFIGURED_WARNING = "Head Tracking is not configured. " +
            "Use HeadTracking.configure() to configure."
    private static let CONFIGURE_ONCE_WARNING = "Head Tracking should only be configured once. " +
            "Attempts to configure head tracking after the first will be ignored."
    private static let CANNOT_BE_CONFIGURED_NOT_SUPPORTED = "Head Tracking cannot be configured. " +
            "It is not supported on this device."
    private static let CANNOT_BE_ENABLED_NOT_CONFIGURED = "Head Tracking cannot be enabled. " +
            HeadTracking.NOT_CONFIGURED_WARNING
    private static let CANNOT_BE_ENABLED_APP_NO_AUTHORIZATION = "Head Tracking cannot be enabled. " +
            "It is either not supported or authorized on the device."
    private static let FAILED_TO_ENABLE_COMPETING_PROCESS = "Head Tracking failed to enable. " +
            "Head Tracking is in the process of being enabled in a separate thread."
    private static let FEATURE_CONFIGURED = "%@ configured."
    private static let FEATURE_ALREADY_CONFIGURED = "%@ already configured. HTFeatures cannot be configured twice."
    private static let ENABLED_THROUGH_USER_SETTINGS_CHANGE = "Head Tracking was enabled through user settings change."
    private static let ENABLE_FAILED_THROUGH_USER_SETTINGS_CHANGE = "Head Tracking failed to enable through user settings change."
    private static let DISABLED_THROUGH_USER_SETTINGS_CHANGE = "Head Tracking was disabled through user settings change."
    private static let MUST_BE_CONFIGURED_TO_CHECK_DEVICE_SUPPORT =
            "Head Tracking must be configured before device support can be assessed."
    private static let MUST_BE_CONFIGURED_TO_CHECK_DEVICE_AUTHORIZATION =
            "Head Tracking must be configured before device authorization can be assessed."
    
    @objc public static var appName: String {
        return Bundle.main.infoDictionary!["CFBundleName"] as? String ?? ""
    }

    // MARK: Features enabled by default configuration
    @objc public static let DEFAULT_FEATURES: [HTFeature.Type] = [
        BannerWarningsFeature.self,
        CursorBlinkClickFeature.self,
        CursorDrawFeature.self,
        CursorDwellClickFeature.self,
        CursorFocusAndClickAnimationFeature.self,
        CursorFocusFeature.self,
        CursorRecalibrationFeature.self
    ]

    // MARK: Singleton Initialization
    @objc public private(set) static var shared: HeadTracking = HeadTracking()
    
    // MARK: Public Fields (get only)
    @objc public private(set) var engine: HTEngine?
    @objc public private(set) var features: [HTFeature] = []
    @objc public private(set) var settings: HTSettings = DefaultSettings.shared

    // MARK: Public Fields (get/set)
    @objc public var analytics: HTAnalytics = HTDefaultAnalytics()

    @available(iOS 13.0, *)
    @objc public lazy var windowScene: UIWindowScene? = nil

    // MARK: Internal
    private var configured = false
    
    override private init() {
        super.init()
        NotificationCenter.default.addObserver(self,
            selector: #selector(self.onSettingsUpdateNotification(_:)),
            name: .htOnHeadTrackingSettingsUpdateNotification, object: nil)
    }

    // MARK: Head Tracking Configuration
    @objc public static func configure(withEngine engineType: HTEngine.Type,
                                       withFeatures features: [HTFeature.Type] = DEFAULT_FEATURES,
                                       withSettingsAppGroup appGroup: String? = nil) {
        if !shared.configured {
            if let appGroup = appGroup {
                shared.settings = StoredSettings(appGroup: appGroup)
            } else {
                shared.settings = InMemorySettings()
            }
            shared.engine = engineType.init(engineSettings: shared.settings)
            
            if HeadTracking.shared.isSupportedByDevice {
                features.forEach { configureFeature($0) }
                shared.configured = true
                NSLog(CONFIGURED_SUCCESSFULLY)
            } else {
                NSLog(CANNOT_BE_CONFIGURED_NOT_SUPPORTED)
            }
        } else {
            NSLog(CONFIGURE_ONCE_WARNING)
        }
    }
    
   @objc public static func configureFeature(_ feature: HTFeature.Type) {
    if !shared.features.contains(where: { $0.isKind(of: feature) }) {
            shared.features.append(feature.configure())
            NSLog(FEATURE_CONFIGURED, String(describing: feature))
        } else {
            NSLog(FEATURE_ALREADY_CONFIGURED, String(describing: feature))
        }
    }
    
    public static func getConfigured<T>(feature featureClass: T.Type) -> T? {
        guard let featureClass = featureClass as? HTFeature.Type else { return nil }
        var feature: HTFeature?
        shared.features.forEach { if $0.isKind(of: featureClass) { feature = $0 } }
        return feature as? T
    }
    
    @discardableResult
    @objc public static func ifConfigured( _ completion: @escaping (HeadTracking) -> Void) -> Bool {
        guard HeadTracking.shared.configured else {
            NSLog(HeadTracking.NOT_CONFIGURED_WARNING)
            return false
        }
        completion(HeadTracking.shared)
        return true
    }
    
    @objc public static func ifConfiguredElse(
        configuredCompletion: @escaping (HeadTracking) -> (),
        notConfiguredCompletion: @escaping () -> ()) -> Void {
        
        guard HeadTracking.shared.configured else {
            NSLog(HeadTracking.NOT_CONFIGURED_WARNING)
            notConfiguredCompletion()
            return
        }
        configuredCompletion(HeadTracking.shared)
    }
    
    // MARK: Head Tracking Device Status
    @objc public var isSupportedByDevice: Bool {
        
        guard let engine = engine else {
            NSLog(HeadTracking.MUST_BE_CONFIGURED_TO_CHECK_DEVICE_SUPPORT)
            return false
        }
        
        return engine.isSupportedByDevice
    }

    @objc public var isAuthorizedOnDevice: Bool {
        
        guard let engine = engine else {
            NSLog(HeadTracking.MUST_BE_CONFIGURED_TO_CHECK_DEVICE_AUTHORIZATION)
            return false
        }
        
        return engine.isAuthorizedOnDevice
    }

    // MARK: Head Tracking Status
    @objc func onSettingsUpdateNotification(_ notification: NSNotification) {
        
        guard HeadTracking.shared.configured else { return }
        
        guard let settingsUpdateContext = notification.userInfo?[NSNotification.htSettingsUpdateKey]
            as? HTSettingsUpdateContext else { return }
        
        guard settingsUpdateContext.key == DisabledByUserOption.shared.key else { return }
        guard let disabledByUser = settingsUpdateContext.objectValue as? Bool else { return }
        
        if disabledByUser {
            disable()
            NSLog(HeadTracking.DISABLED_THROUGH_USER_SETTINGS_CHANGE)
        } else if let engine = engine, !disabledByUser && !engine.isActivating && !engine.isEnabled {
            enable { success in
                if success {
                    NSLog(HeadTracking.ENABLED_THROUGH_USER_SETTINGS_CHANGE)
                } else {
                    NSLog(HeadTracking.ENABLE_FAILED_THROUGH_USER_SETTINGS_CHANGE)
                }
            }
        }
    }
    
    // MARK: Head Tracking Status
    @objc public var isEnabled: Bool {
        guard configured else { return false }
        guard let engine = engine else { return false }
        guard engine.isAuthorizedOnDevice else { return false }
        guard !settings.disabledByUser else { return false }
        return engine.isEnabled
    }

    @objc public func enable(completion: @escaping (_ success: Bool) -> () = { _ in } ) {
        guard configured else {
            NSLog(HeadTracking.NOT_CONFIGURED_WARNING)
            completion(false)
            return
        }
        
        guard HeadTracking.shared.isAuthorizedOnDevice else {
            NSLog(HeadTracking.CANNOT_BE_ENABLED_APP_NO_AUTHORIZATION)
            completion(false)
            return
        }
        
        if !settings.disabledByUser {
            engine?.enable()
            self.features.forEach { if !$0.enabled { $0.enable() } }
            NSLog(HeadTracking.ENABLED_SUCCESSFULLY)
            completion(true)
        } else {
            NSLog(HeadTracking.DISABLED_IN_SETTINGS)
            completion(false)
        }
    }

    @objc public func disable() {
        guard configured else { return }
        guard HeadTracking.shared.isAuthorizedOnDevice else { return }
        engine?.disable()
        features.forEach { if $0.enabled { $0.disable() } }
        NSLog(HeadTracking.DISABLED)
    }

    @objc public func recalibrateImmediately() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .htOnRecalibrateNotification, object: nil)
        }
    }

}
