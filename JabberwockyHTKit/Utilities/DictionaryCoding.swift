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

@objc public class DictionaryCodable: NSObject {
    
    private static let encoder = JSONEncoder()

    public static func encode<T: Encodable>(_ context: T) -> [String: Any]? {
        do {
            let json = try encoder.encode(context)
            if let dictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any] {
                return dictionary
            }
        } catch let error {
            NSLog("Error encoding context: " + error.localizedDescription)
        }
        return nil
    }
}
