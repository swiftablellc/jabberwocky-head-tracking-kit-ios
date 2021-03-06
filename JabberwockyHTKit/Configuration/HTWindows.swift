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

@objc public class HTWindows: NSObject {
    
    private static let HIGHEST_WINDOW_FLOAT = CGFloat(500000000)
    private static let WINDOW_FLOAT_INCREMENT = CGFloat(1000)
    
    private static let DEFAULT_CURSOR_DRAW_WL = UIWindow.Level(HIGHEST_WINDOW_FLOAT)
    private static let DEFAULT_FOCUS_AND_CLICK_ANIMATION_WL = DEFAULT_CURSOR_DRAW_WL - WINDOW_FLOAT_INCREMENT
    private static let DEFAULT_CURSOR_FOCUS_WL = DEFAULT_FOCUS_AND_CLICK_ANIMATION_WL - WINDOW_FLOAT_INCREMENT
    private static let DEFAULT_TOOLTIP_WL = DEFAULT_CURSOR_FOCUS_WL - WINDOW_FLOAT_INCREMENT
    private static let DEFAULT_MENU_WL = DEFAULT_TOOLTIP_WL - WINDOW_FLOAT_INCREMENT
    private static let DEFAULT_FACE_MESH_WL = DEFAULT_MENU_WL - WINDOW_FLOAT_INCREMENT

    @objc public static var cursorDrawWindowLevel = DEFAULT_CURSOR_DRAW_WL
    @objc public static var focusAndClickAnimationWindowLevel = DEFAULT_FOCUS_AND_CLICK_ANIMATION_WL
    @objc public static var cursorFocusWindowLevel = DEFAULT_CURSOR_FOCUS_WL
    @objc public static var tooltipWindowLevel = DEFAULT_TOOLTIP_WL
    @objc public static var menuWindowLevel = DEFAULT_MENU_WL
    @objc public static var faceMeshWindowLevel = DEFAULT_FACE_MESH_WL
    
    // MARK: Singleton Initialization
    @objc public private(set) static var shared: HTWindows = HTWindows()
    
    override private init() { }
    
    // MARK: Window Registry
    private var windowRegistry: [String: UIWindow] = [:]
    
    @objc public func getWindow(for feature: HTFeature) -> UIWindow? {
        let featureName = String(describing: type(of: feature))
        return windowRegistry[featureName]
    }
    
    @discardableResult
    public func enable<T>(for feature: HTFeature, of windowType: T.Type) -> T where T: UIWindow {
        let featureName = String(describing: type(of: feature))
        return enable(for: featureName, of: windowType)
    }

    @objc public func disable(for feature: HTFeature) {
        let featureName = String(describing: type(of: feature))
        return disable(for: featureName)
    }
    
    @available(iOS 13, *)
    @objc public func handleWindowSceneUpdate(_ windowScene: UIWindowScene?) {
        for enabledWindowFeature in windowRegistry.keys {
            windowRegistry[enabledWindowFeature]?.windowScene = windowScene
        }
    }
    
    @discardableResult
    private func enable<T>(for featureName: String, of _ : T.Type) -> T where T: UIWindow {
        if let existingWindow = windowRegistry[featureName] as? T {
            return existingWindow
        }
        let newWindow: T
        if #available(iOS 13, *), HeadTracking.shared.windowScene != nil {
            newWindow = T(windowScene: HeadTracking.shared.windowScene!)
        } else {
            newWindow = T(frame: UIScreen.main.bounds)
        }
        windowRegistry[featureName] = newWindow
        newWindow.rootViewController = UIViewController()
        if let keyWindow = UIApplication.shared.keyWindow {
            newWindow.makeKeyAndVisible()
            keyWindow.makeKey()
        } else {
            newWindow.makeKeyAndVisible()
        }
        return newWindow
    }
    
    private func disable(for featureName: String) {
        guard let window = windowRegistry[featureName] else { return }
        windowRegistry[featureName] = nil
        let windowStillActive = windowRegistry.values.contains(window)
        if !windowStillActive {
            var windows = UIApplication.shared.windows
            windows.removeAll { appWindow in appWindow == window }
        }
    }
}
