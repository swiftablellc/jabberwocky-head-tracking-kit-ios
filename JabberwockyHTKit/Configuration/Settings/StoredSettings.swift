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

import CoreGraphics

@objc public class StoredSettings: InMemorySettings {

    @objc public static let KEY_PREFIX = "Jabberwocky/v1/"

    @objc public private(set) var appGroup: String?
    private var userDefaults: UserDefaults?

    init(appGroup: String) {
        self.appGroup = appGroup
        self.userDefaults = UserDefaults(suiteName: appGroup)
        super.init()
        initialize()
    }
    
    private func initialize() {
        for element in userDefaults?.dictionaryRepresentation() ?? [:] {
            if element.key.hasPrefix(StoredSettings.KEY_PREFIX) {
                NSLog("\(element.key) loaded using stored option: \(element.value)")
                setOption(String(element.key.dropFirst(StoredSettings.KEY_PREFIX.count)), element.value)
            }
        }
    }
    
    @discardableResult
    override public func setObject(_ key: String, _ objectValue: Any) -> Bool {
        guard let optionSpec = optionSpecifications[key] else { return false }
        guard let optionValue = optionSpec.toOptionValue(objectValue: objectValue) else { return false}
        updateInMemory(key: key, objectValue: objectValue, optionValue: optionValue, optionSpec: optionSpec)
        updateStored(key: key, optionValue: optionValue)
        return true
    }

    @discardableResult
    override public func setOption(_ key: String, _ optionValue: Any) -> Bool {
        guard let optionSpec = optionSpecifications[key] else { return false }
        guard let objectValue = optionSpec.toObjectValue(optionValue: optionValue) else { return false}
        updateInMemory(key: key, objectValue: objectValue, optionValue: optionValue, optionSpec: optionSpec)
        updateStored(key: key, optionValue: optionValue)
        return true
    }
    
    internal func updateStored(key: String, optionValue: Any) {
        let keyPath = StoredSettings.KEY_PREFIX + key
        userDefaults?.setValue(optionValue, forKeyPath: keyPath)
    }

}
