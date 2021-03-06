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

import UIKit.UIView

// FIXME: Move this objc garbage somewhere else
internal class BoolResultWrapper: NSObject {
    let closure: () -> Bool
    init(_ closure: @escaping () -> Bool) {
        self.closure = closure
    }
}

@objc public protocol HTFocusable: class {
    
    var htClickSound: HTSounds.Sound { get set }
    /*
     htFocusLevel must be between 0.0 and 1.0 where 1.0 indicates fully focused.
     */
    var htFocusLevel: Float { get set }
    var htIsFocusable: () -> Bool { get set }
    var htTooltipText: String? { get set }
    
    func htFrameInScreenCoordinates() -> CGRect
    func htHandleTooShortClick()
    func htIgnoresCursorMode() -> Bool
    func htIgnoresScrollSpeed() -> Bool
    func htInitiateAction(_ screenPoint: CGPoint)

}
