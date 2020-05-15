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
import JabberwockyHTKitCore

 
public class HeadMovementCorrectionOption: HTSettingsOptionSpecTyped {
    public typealias ObjectType = HeadMovementCorrection
    public typealias OptionType = String
    
    private init() {}
    public static let shared = HeadMovementCorrectionOption()
    
    public var key = "headMovementCorrection"
    public var defaultObjectValueTyped = HeadMovementCorrection(option: HeadMovementCorrection.Option.Low)
    public var valueChangedClosure: () -> Void = { }
    
    public func toObjectValueTyped(optionValue: String) -> HeadMovementCorrection? {
        if let hmcOption = HeadMovementCorrection.Option.init(rawValue: optionValue) {
            return HeadMovementCorrection(option: hmcOption)
        }
        return nil
    }
    
    public func toOptionValueTyped(objectValue: HeadMovementCorrection) -> String? {
        return objectValue.option.rawValue
    }

}
