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


/*
 Once configured the RemoteSettingsFeature is automatically enabled.
 We don't want disabling head tracking to stop this feature from
 accepting notifications (i.e. disabledByUser = false) that would
 enable Head Tracking.
 */
@objc public class RemoteSettingsFeature: NSObject, HTFeature {

    // MARK: Singleton Initialization
    @objc public private(set) static var shared: RemoteSettingsFeature?

    override private init() { }

    @objc public static func configure() -> HTFeature {
        if RemoteSettingsFeature.shared == nil {
            let feature = RemoteSettingsFeature()
            RemoteSettingsFeature.shared = feature
            NotificationCenter.default.addObserver(
                feature, selector: #selector(feature.onSettingsRequestNotification(_:)),
                name: .htOnSettingsRequestNotification, object: nil)
        }
        return RemoteSettingsFeature.shared!
    }

    // MARK: HTFeature protocol
    @objc public private(set) var enabled = true

    @objc public func enable() { }

    @objc public func disable() { }
    
    // MARK: Internal
    
    @objc func onSettingsRequestNotification(_ notification: NSNotification) {
        
        guard let requestContext = notification.userInfo?[NSNotification.htRequestContextKey]
            as? HTRequestContext else { return }

        if let requestType = requestContext["requestType"] as? String {
            if requestType.caseInsensitiveCompare("GetSettingsRequest") == .orderedSame {
                let eventBody: [String: Any]
                let responseBody = HeadTracking.shared.settings.getOptions()
                let remoteResponse: [String: Any] =
                    ["responseType": "HTSettingsResponse", "responseBody": responseBody as Any]
                eventBody = ["remoteRequest": requestContext, "remoteResponse": remoteResponse]
                sendRemoteResponseEvent(eventBody, false)
            } else if requestType.caseInsensitiveCompare("UpdateSettingsRequest") == .orderedSame {
                let success = trySettingsUpdate(requestContext)
                let eventBody: [String: Any]
                let responseBody = success ? HeadTracking.shared.settings.getOptions() : nil
                let remoteResponse: [String: Any] =
                    ["responseType": "HTSettingsResponse", "responseBody": responseBody as Any]
                eventBody = ["remoteRequest": requestContext, "remoteResponse": remoteResponse]
                sendRemoteResponseEvent(eventBody, responseBody != nil ? false : true)
            }
        }
    }
    
    private func trySettingsUpdate(_ requestContext: HTRequestContext) -> Bool {
        guard let requestBody = requestContext["requestBody"] as? [String: Any] else { return false }
        guard let settingsKey = requestBody["settingsKey"] as? String else { return false }
        guard let settingsValue = requestBody["settingsValue"] else { return false }
        return HeadTracking.shared.settings.setOption(settingsKey, settingsValue)
    }

    private func sendRemoteResponseEvent(_ eventBody: [String: Any], _ eventError: Bool) {
        var eventDictionary: [String: Any] = [:]
        eventDictionary["eventType"] = "HTRemoteResponseEvent"
        eventDictionary["eventBody"] = eventBody
        eventDictionary["eventError"] = eventError
        let eventContext = HTEventContext(dictionary: eventDictionary)
        NSLog(String(describing: eventContext))
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .htEventNotification, object: nil,
                userInfo: [NSNotification.htEventContextKey: eventContext])
        }
    }
}
