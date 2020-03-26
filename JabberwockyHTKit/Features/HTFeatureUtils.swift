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

@objc public class SynthFocusHitTestEvent: UIEvent { }

@objc public class SynthScrollHitTestEvent: UIEvent { }

@objc public class HTFeatureUtils: NSObject {

    @objc public static func getHittableWindowStack() -> [UIWindow] {
        var windowLevelMap = [UIWindow.Level:UIWindow]()
        for window in UIApplication.shared.windows {
            windowLevelMap[window.windowLevel] = window
        }
        var windowStack = [UIWindow]()

        var sortedStack = windowLevelMap.keys.sorted()
        sortedStack.reverse()
        for level in sortedStack {
            let window: UIWindow = windowLevelMap[level]!
            if !window.isHidden {
                windowStack.append(window)
            }
        }
        return windowStack
    }
    
    @objc public static func getFocusableViews(in windows: [UIWindow] = getHittableWindowStack()) -> [UIView] {
        var focusableViews: [UIView] = []
        for window in windows {
            for focusableView in getFocusableViews(in: window) {
                focusableViews.append(focusableView)
            }
        }
        return focusableViews
    }

    public static func getFocusableViews(in view: UIView) -> [UIView] {
        var result: [UIView] = []
        
        if let focusableView = view as? HTFocusable, focusableView.htIsFocusable() {
            result.append(view)
        }
        for subview in view.subviews {
            result.append(contentsOf: getFocusableViews(in: subview))
        }
        return result
    }

    @objc public static func getHitElement(at screenPoint: CGPoint,
                                     in windows: [UIWindow] = getHittableWindowStack(),
                                     with hitEvent: UIEvent? = nil) -> UIView? {
        if let window = windows.first {
            // If the hitTest comes back positive we probably want to stop recursion through windows
            if let hitElement = window.hitTest(screenPoint, with: hitEvent) {
                return hitElement
            } else {
                var windowsBelow = windows
                windowsBelow.removeFirst()
                return getHitElement(at: screenPoint, in: windowsBelow, with: hitEvent)
            }
        }
        return nil
    }
    
    public static func firstViewOfType<T>(_ type: T.Type, inHierarchyOf view: UIView?) -> T? {
        guard let view = view else { return nil }
        if let viewOfType = view as? T {
            return viewOfType
        } else {
            return firstViewOfType(type, inHierarchyOf: view.superview)
        }
    }

    @objc public static func isViewEqualOrAncestor(_ ancestor: UIView, of view: UIView?) -> Bool {
        guard let view = view else { return false }
        if view == ancestor {
            return true
        } else {
            return isViewEqualOrAncestor(ancestor, of: view.superview)
        }
    }
}
