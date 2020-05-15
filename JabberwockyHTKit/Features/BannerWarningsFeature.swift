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

@objc public class BannerWarningsFeature: NSObject, HTFeature {

    // MARK: Singleton Initialization
    @objc public private(set) static var shared: BannerWarningsFeature?
    
    override private init() {
        // TODO: I18N these messages and make them configurable...
        let faceLostMessage = "Face not detected!  The cursor is disabled."
        faceLostBanner = StatusBarNotificationBanner(title: faceLostMessage, style: .danger)
        faceLostBanner.duration = CFTimeInterval.infinity
        let resetReminderMessage = "Shake your head left and right quickly to recalibrate."
        resetReminderBanner = StatusBarNotificationBanner(title: resetReminderMessage, style: .warning)
        resetReminderBanner.duration = CFTimeInterval.infinity
        let faceTooCloseMessage = "Move your face further from the device for better results."
        faceTooCloseBanner = StatusBarNotificationBanner(title: faceTooCloseMessage, style: .warning)
        faceTooCloseBanner.duration = CFTimeInterval.infinity
        let faceTooFarMessage = "Move your face closer to the device for better results."
        faceTooFarBanner = StatusBarNotificationBanner(title: faceTooFarMessage, style: .warning)
        faceTooFarBanner.duration = CFTimeInterval.infinity
    }
    
    @objc public static func configure() -> HTFeature {
        if BannerWarningsFeature.shared == nil {
            BannerWarningsFeature.shared = BannerWarningsFeature()
        }
        return BannerWarningsFeature.shared!
    }
    
    // MARK: HTFeature protocol
    @objc public private(set) var enabled = false
    
    @objc public func enable() {
        if !enabled {
            enabled = true
            NotificationCenter.default.addObserver(
                self, selector: #selector(self.onBannerUpdateNotification),
                name: .htOnWarningNotification, object: nil)
        }
    }
    
    @objc public func disable() {
        if enabled {
            enabled = false
            NotificationCenter.default.removeObserver(self, name: .htOnWarningNotification, object: nil)
        }
    }

    // MARK: Internal
    private var faceLostBanner: StatusBarNotificationBanner!
    private var resetReminderBanner: StatusBarNotificationBanner!
    private var faceTooCloseBanner: StatusBarNotificationBanner!
    private var faceTooFarBanner: StatusBarNotificationBanner!
    
    @objc func onBannerUpdateNotification(_ notification: NSNotification)  {
        guard let warningContext = notification.userInfo?[NSNotification.htWarningContextKey]
            as? HTWarningContext else {
            return
        }
        let banner = { () -> StatusBarNotificationBanner? in
            switch warningContext.warning {
            case .faceLost:
                return faceLostBanner
            case .faceTooClose:
                return faceTooCloseBanner
            case .faceTooFar:
                return faceTooFarBanner
            case .resetReminder:
                return resetReminderBanner
            default:
                return nil
            }
        }()
        warningContext.active ? banner?.show() : banner?.dismiss()
    }
}

