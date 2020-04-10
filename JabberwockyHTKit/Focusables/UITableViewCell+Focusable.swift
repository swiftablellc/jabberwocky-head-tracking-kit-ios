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

extension UITableViewCell: HTFocusable {
    
    private func DEFAULT_HT_IS_FOCUSABLE() -> Bool {
        return self.selectionStyle != .none
    }
    
    private struct Props {
        static var htClickSound: HTSounds.Sound = .click
        static var htFocusLevel: Float = 0.0
        static var htIsFocusable: BoolResultWrapper = BoolResultWrapper{ return true }
        static var htTooltipText: String? = nil
    }
    
    @objc public var htClickSound: HTSounds.Sound {
        get {
            guard let value = objc_getAssociatedObject(self, &Props.htClickSound) as? HTSounds.Sound else {
                return .click
            }
            return value
        }
        set {
            objc_setAssociatedObject(self, &Props.htClickSound, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    
    @objc public var htFocusLevel: Float {
        get {
            guard let value = objc_getAssociatedObject(self, &Props.htFocusLevel) as? Float else {
                return 0.0
            }
            return value
        }
        set {
            let inRangeValue = max(0.0, min(1.0, newValue))
            objc_setAssociatedObject(self, &Props.htFocusLevel, inRangeValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    @objc public var htIsFocusable: () -> Bool {
        get {
            guard let wrapper = objc_getAssociatedObject(self, &Props.htIsFocusable) as? BoolResultWrapper else {
                return DEFAULT_HT_IS_FOCUSABLE
            }
            return wrapper.closure
        }
        set {
            objc_setAssociatedObject(self, &Props.htIsFocusable, BoolResultWrapper(newValue), .OBJC_ASSOCIATION_RETAIN)
        }
    }

    @objc public var htTooltipText: String? {
        get {
            guard let value = objc_getAssociatedObject(self, &Props.htTooltipText) as? String? else {
                return nil
            }
            return value
        }
        set {
            objc_setAssociatedObject(self, &Props.htTooltipText, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    @objc public func htFrameInScreenCoordinates() -> CGRect {
        return self.convert(self.bounds, to: nil)
    }
    
    @objc public func htIgnoresCursorMode() -> Bool {
        return false
    }
    
    @objc public func htIgnoresScrollSpeed() -> Bool {
        return false
    }

    @objc public func htInitiateAction(_ screenPoint: CGPoint) {
        if let table = self.superview as? UITableView {
            let indexPath = table.indexPath(for: self)!
            if !self.isSelected {
                table.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                table.delegate?.tableView!(table, didSelectRowAt: indexPath)
            } else {
                table.deselectRow(at: indexPath, animated: true)
                table.delegate?.tableView!(table, didDeselectRowAt: indexPath)
            }
        }
    }

    @objc public func htHandleTooShortClick() { }

}
