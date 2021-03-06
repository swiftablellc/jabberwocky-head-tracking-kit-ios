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

@objc public enum HTWarning: Int, Codable {
    case faceLost
    case faceTooClose
    case faceTooFar
    case resetReminder
}

@objc public class HTWarningContext: NSObject, Codable {

    @objc public let active: Bool
    @objc public let warning: HTWarning
    
    @objc public init(_ warning: HTWarning, _ active: Bool = true){
        self.active = active
        self.warning = warning
    }
}
