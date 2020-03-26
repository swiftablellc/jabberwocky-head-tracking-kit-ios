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

@objc public class HTKeyboard: NSObject {
    
    //MARK: Singleton Initialization
    @objc public private(set) static var shared: HTKeyboard = HTKeyboard()
    
    @objc public private(set) var isVisible: Bool = false
    
    //MARK: Internal
    override private init() {
        super.init()
        // Notifications
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.keyboardUpdateNotification(_:)),
            name: .onKeyboardUpdateNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self, name: .onKeyboardUpdateNotification, object: nil)
    }
    
    @objc private func keyboardUpdateNotification(_ notification: NSNotification)  {
        if let isVisible = notification.userInfo?[NSNotification.keyboardIsVisibleKey] as? Bool {
            self.isVisible = isVisible
        }
    }
}
