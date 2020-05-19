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

@objc public class CoreEventProxyFeature: NSObject, HTFeature {

    // MARK: Singleton Initialization
    @objc public private(set) static var shared: CoreEventProxyFeature?

    override private init() { }

    @objc public static func configure() -> HTFeature {
        if CoreEventProxyFeature.shared == nil {
            CoreEventProxyFeature.shared = CoreEventProxyFeature()
        }
        return CoreEventProxyFeature.shared!
    }

    // MARK: HTFeature protocol
    @objc public private(set) var enabled = false

    @objc public func enable() {
        if !enabled {
            enabled = true
            NotificationCenter.default.addObserver(
                    self, selector: #selector(self.onBlinkNotification(_:)),
                    name: .htOnBlinkNotification, object: nil)
            NotificationCenter.default.addObserver(
                    self, selector: #selector(self.onCursorUpdateNotification(_:)),
                    name: .htOnCursorUpdateNotification, object: nil)
            NotificationCenter.default.addObserver(
                    self, selector: #selector(self.onWarningNotification(_:)),
                    name: .htOnWarningNotification, object: nil)
        }
    }

    @objc public func disable() {
        if enabled {
            enabled = false
            NotificationCenter.default.removeObserver(self, name: .htOnBlinkNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: .htOnCursorUpdateNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: .htOnWarningNotification, object: nil)
        }
    }

    // MARK: Internal
    
    @objc func onBlinkNotification(_ notification: NSNotification) {
        guard let blinkContext = notification.userInfo?[NSNotification.htBlinkContextKey]
            as? HTBlinkContext else { return }
        let eventBody = DictionaryCodable.encode(blinkContext)
        sendEvent(eventBody, "HTBlinkEvent", eventBody != nil ? false : true)
    }
    
    @objc func onCursorUpdateNotification(_ notification: NSNotification) {
        
        guard let cursorContext = notification.userInfo?[NSNotification.htCursorContextKey]
            as? HTCursorContext else { return }
        let eventBody = DictionaryCodable.encode(cursorContext)
        sendEvent(eventBody, "HTCursorEvent", eventBody != nil ? false : true)
    }
    
    @objc func onWarningNotification(_ notification: NSNotification) {
        
        guard let warningContext = notification.userInfo?[NSNotification.htWarningContextKey]
            as? HTWarningContext else { return }
        let eventBody = DictionaryCodable.encode(warningContext)
        sendEvent(eventBody, "HTWarningEvent", eventBody != nil ? false : true)
    }
    
    private func sendEvent(_ eventBody: [String: Any]?, _ eventType: String, _ eventError: Bool) {
        var eventDictionary: [String: Any] = [:]
        eventDictionary["eventType"] = eventType
        eventDictionary["eventBody"] = eventBody
        eventDictionary["eventError"] = eventError
        let eventContext = HTEventContext(dictionary: eventDictionary)
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .htEventNotification, object: nil,
                userInfo: [NSNotification.htEventContextKey: eventContext])
        }
    }

}
