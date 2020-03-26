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

class ThemeColors {
    //Theme colors
    static let darkishPurple = UIColor(hue: 259.0 / 360.0, saturation: 0.86, brightness: 0.75, alpha: 1)
    
    //Exaggerated version of theme color (for highlighting)
    static let purePurple = UIColor(hue: 262.0 / 360.0, saturation: 1.0, brightness: 1.0, alpha: 1)
    
    //Grays with tinge of primary theme (purple)
    static let lightGray = UIColor(hue: 282.0 / 360.0, saturation: 0.03, brightness: 0.9, alpha: 1)
    static let veryLightGray = UIColor(hue: 282.0 / 360.0, saturation: 0.02, brightness: 0.95, alpha: 1)
    
    //Generic colors that transcend theme
    static let clear = UIColor.clear
    static let black = UIColor.black
    
    static let standardBackground = lightGray
    static let primaryButton = darkishPurple
}

class ThemeObjects {
    static let calibrationCircleSize: CGFloat = {
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return 160
        case .pad:
            return 240
        default:
            return 160
        }
    }()
}

class ThemeFonts {
    static let gigantic: UIFont = {
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return UIFont.systemFont(ofSize: 72)
        case .pad:
            return UIFont.systemFont(ofSize: 108)
        default:
            return UIFont.systemFont(ofSize: UIFont.systemFontSize * 3.6)
        }
    }()
    static let huge: UIFont = {
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return UIFont.systemFont(ofSize: 48)
        case .pad:
            return UIFont.systemFont(ofSize: 72)
        default:
            return UIFont.systemFont(ofSize: UIFont.systemFontSize * 2.4)
        }
    }()
    static let veryLarge: UIFont = {
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return UIFont.systemFont(ofSize: 32)
        case .pad:
            return UIFont.systemFont(ofSize: 48)
        default:
            return UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.5)
        }
    }()
    static let large: UIFont = {
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return UIFont.systemFont(ofSize: 24)
        case .pad:
            return UIFont.systemFont(ofSize: 36)
        default:
            return UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.2)
        }
    }()
    static let medium: UIFont = {
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return UIFont.systemFont(ofSize: 20)
        case .pad:
            return UIFont.systemFont(ofSize: 30)
        default:
            return UIFont.systemFont(ofSize: UIFont.systemFontSize)
        }
    }()
    static let small: UIFont = {
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return UIFont.systemFont(ofSize: 16)
        case .pad:
            return UIFont.systemFont(ofSize: 24)
        default:
            return UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        }
    }()
    static let smallest: UIFont = {
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return UIFont.systemFont(ofSize: 12)
        case .pad:
            return UIFont.systemFont(ofSize: 18)
        default:
            return UIFont.systemFont(ofSize: UIFont.systemFontSize * 0.6)
        }
    }()

}

