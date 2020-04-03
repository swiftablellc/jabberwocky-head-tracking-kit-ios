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

@objc public class ThemeColors: NSObject {
    
    //TODO: Expand theme reach and find appropriate names. There are lots of hardcoded pieces.

    //Theme colors
    private static let darkishPurple = UIColor(hue: 259.0 / 360.0, saturation: 0.86, brightness: 0.75, alpha: 1)
    
    //Exaggerated version of theme color (for highlighting)
    private static let purePurple = UIColor(hue: 262.0 / 360.0, saturation: 1.0, brightness: 1.0, alpha: 1)
    
    //Grays with tinge of primary theme (purple)
    private static let lightGray = UIColor(hue: 282.0 / 360.0, saturation: 0.03, brightness: 0.9, alpha: 1)
    
    public static var cursorPulse = darkishPurple
    public static var highlight = purePurple
    public static var primary = darkishPurple
    public static var primaryText = UIColor.black
    public static var secondaryText = UIColor.gray
    public static var standardBackground = lightGray
    
}

@objc class CalibrationTheme: NSObject {
    
    public static var calibrationText = "Look Here..."

    public static var circleSize: CGFloat = {
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return 160
        case .pad:
            return 240
        default:
            return 160
        }
    }()

    public static var primaryLabelFont: UIFont = { () -> UIFont in
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return UIFont.systemFont(ofSize: 48)
        case .pad:
            return UIFont.systemFont(ofSize: 72)
        default:
            return UIFont.systemFont(ofSize: UIFont.systemFontSize * 2.4)
        }
        }().htBold()

    public static var secondaryLabelFont: UIFont = {
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return UIFont.systemFont(ofSize: 20)
        case .pad:
            return UIFont.systemFont(ofSize: 30)
        default:
            return UIFont.systemFont(ofSize: UIFont.systemFontSize)
        }
    }()
}
