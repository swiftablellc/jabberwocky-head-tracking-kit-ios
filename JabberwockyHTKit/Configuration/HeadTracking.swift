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

import ARKit
import JabberwockyHTKitCore

@objc public class HeadTracking: NSObject {
    
    // MARK: Framework Bundle
    internal static let FRAMEWORK_BUNDLE = Bundle(for: HeadTracking.self)

    // MARK: INFO and WARNINGs
    private static let CONFIGURED_SUCCESSFULLY = "Head Tracking configured successfully."
    private static let ENABLED_SUCCESSFULLY = "Head Tracking enabled successfully."
    private static let DISABLED_IN_SETTINGS = "Head Tracking was not enabled because it was disabled " +
            "in settings and not enabled with overrideSettings = true."
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
    private static let FEATURE_CONFIGURED = "%@ configured and %@."
    private static let FEATURE_ALREADY_CONFIGURED = "%@ already configured. HTFeatures cannot be configured twice."

    // MARK: Features enabled by default configuration
    @objc public static let DEFAULT_ENABLED_FEATURES: [HTFeature.Type] = [
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
    @objc public private(set) var features: [HTFeature] = []

    // MARK: Public Fields (get/set)
    @objc public var analytics: HTAnalytics = HTDefaultAnalytics()
    @objc public var settings: HTSettings = ImmutableDefaultSettings()
    
    // MARK: Internal
    private var configured = false
    
    override private init() { }

    // MARK: Head Tracking Configuration
    @objc public static func configure(withEnabledFeatures features: [HTFeature.Type] = DEFAULT_ENABLED_FEATURES,
                                       withSettingsAppGroup appGroup: String? = nil) {
        if !shared.configured {
            if let appGroup = appGroup {
                shared.settings = StoredSettings(appGroup: appGroup)
            } else {
                shared.settings = InMemorySettings()
            }
            HeadTrackingCore.configure(settings: shared.settings)
            
            if HeadTrackingCore.shared.isSupportedByDevice {
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
    
   @objc public static func configureFeature(_ feature: HTFeature.Type, enabled: Bool = true) {
    if !shared.features.contains(where: { $0.isKind(of: feature) }) {
            shared.features.append(feature.configure(withFeatureEnabled: enabled))
            NSLog(FEATURE_CONFIGURED, String(describing: feature), enabled ? "enabled" : "disabled")
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

    // MARK: Head Tracking Status
    @objc public var isEnabled: Bool {
        guard HeadTrackingCore.shared.isAuthorizedOnDevice else { return false }
        guard HeadTracking.shared.configured else { return false }
        guard !HeadTracking.shared.settings.disabledByUser else { return false }
        var isCameraActive = false
        if let cameraWindow = HTWindows.shared.cameraWindow {
            isCameraActive = cameraWindow.cameraViewController != nil
        }
        return isCameraActive
    }

    @objc public func enable(overrideDisabledFlag: Bool = false,
                             completion: @escaping (_ success: Bool) -> () = { _ in } ) {
        guard HeadTracking.shared.configured else {
            NSLog(HeadTracking.NOT_CONFIGURED_WARNING)
            completion(false)
            return
        }
        
        guard HeadTrackingCore.shared.isAuthorizedOnDevice else {
            NSLog(HeadTracking.CANNOT_BE_ENABLED_APP_NO_AUTHORIZATION)
            completion(false)
            return
        }
        
        if overrideDisabledFlag || !HeadTracking.shared.settings.disabledByUser {
            HeadTracking.shared.settings.disabledByUser = false
            HeadTracking.shared.activateCameraWindow() {
                NSLog(HeadTracking.ENABLED_SUCCESSFULLY)
                completion(true)
            }
        } else {
            NSLog(HeadTracking.DISABLED_IN_SETTINGS)
            completion(false)
        }
    }

    @objc public func disable(andAlsoUpdateSettings: Bool = false) {
        guard HeadTrackingCore.shared.isAuthorizedOnDevice else { return }
        HeadTracking.ifConfigured { headTracking in
            if andAlsoUpdateSettings {
                headTracking.settings.disabledByUser = true
            }
            headTracking.deactivateCameraWindow()
        }
    }

    @objc public func recalibrateImmediately() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .htOnRecalibrateNotification, object: nil)
        }
    }

    private func activateCameraWindow(preventCalibration: Bool = false,
                                      completion: @escaping ()->()) {
        if let _ = HTWindows.shared.cameraWindow {
            let needsCalibration = !HeadTrackingCore.shared.hasCalibratedOnce && !preventCalibration
            notifyCameraWindowActivated(needsCalibration: needsCalibration)
            completion()
        } else {
            HTCameraViewController.initialize { cameraViewController in
                HTWindows.shared.enableCameraWindow(cameraViewController)
                let needsCalibration = !preventCalibration
                self.notifyCameraWindowActivated(needsCalibration: needsCalibration)
                completion()
            }
        }
    }

    private func notifyCameraWindowActivated(needsCalibration: Bool) {
        // Always send a notification of a potential change in the status of head tracking
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .htOnHeadTrackingStatusUpdateNotification, object: nil)
            if needsCalibration {
                NotificationCenter.default.post(name: .htInitiateRecalibrationCountdownNotification, object: nil)
            }
        }
    }

    private func deactivateCameraWindow() {
        // Executes cameraViewController.viewWillDisappear and .viewDidDisappear as tear down
        HTWindows.shared.disableCameraWindow()
        // Always send a notification of a potential change in the status of head tracking
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .htOnHeadTrackingStatusUpdateNotification, object: nil)
        }
    }
}
