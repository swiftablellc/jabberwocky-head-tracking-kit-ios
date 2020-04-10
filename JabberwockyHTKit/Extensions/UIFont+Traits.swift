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

import UIKit

extension UIFont {

    func htWithTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: 0) //size 0 means keep the size as it is
        } else {
            return self
        }
    }
    
    func htBold() -> UIFont {
        return htWithTraits(traits: .traitBold)
    }
    
    func htItalic() -> UIFont {
        return htWithTraits(traits: .traitItalic)
    }
    
    func htBoldAndItalic() -> UIFont {
        return htWithTraits(traits: [.traitItalic, .traitBold])
    }
}
