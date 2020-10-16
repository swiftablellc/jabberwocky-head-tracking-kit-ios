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
import CoreGraphics

@objc public protocol HTEngineSettings {

    /**
     @property cursorStickiness
     @abstract Determines the stickiness of the cursor.
     @discussion Stickiness is a value between 0.0 and 1.0, where 0.0 is none and 1.0 is very high resistance to small cursor movement.
     */
    var cursorStickiness: Float {get set}
    /**
     @property horizontalSpeed
     @abstract Determines the horizontal speed of the cursor.
     @discussion Speed is a value between 0.0 and 1.0, where 0.0 is very slow and 1.0 is very high movement relative to the screen.
     */
    var horizontalSpeed: Float {get set}
    /**
     @property verticalSpeed
     @abstract Determines the vertical speed of the cursor.
     @discussion Speed is a value between 0.0 and 1.0, where 0.0 is very slow and 1.0 is very high movement relative to the screen.
     */
    var verticalSpeed: Float {get set}

}
