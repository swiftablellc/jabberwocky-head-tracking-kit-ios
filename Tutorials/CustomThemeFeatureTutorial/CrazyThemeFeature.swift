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

#if JABBERWOCKY_LOCAL_DEV
  import JabberwockyHTKitLocal
#else
  import JabberwockyHTKit
#endif

import UIKit

// TODO: Move this to a Tutorial

public class CrazyThemeFeature: NSObject, HTFeature {

    // MARK: Singleton Initialization
    public private(set) static var shared: CrazyThemeFeature?

    override private init() { }

    public static func configure(withFeatureEnabled enabled: Bool = true) -> HTFeature {
        if CrazyThemeFeature.shared == nil {
            CrazyThemeFeature.shared = CrazyThemeFeature()
            if enabled {
                CrazyThemeFeature.shared?.enable()
            }
        }
        return CrazyThemeFeature.shared!
    }

    // MARK: HTFeature protocol
    public private(set) var enabled = false

    public func enable() {
        enabled = true
        // TODO: Theme control is pretty limited at the moment...
        ThemeColors.cursorPulse = UIColor.green
        ThemeColors.highlight = UIColor.red
        ThemeColors.primary = UIColor.blue
        ThemeColors.primaryText = UIColor.purple
        ThemeColors.secondaryText = UIColor.yellow
        ThemeColors.standardBackground = UIColor.orange

        CalibrationTheme.calibrationText = "Crazy Theme"
        CalibrationTheme.circleSize = {
            switch(UIDevice.current.userInterfaceIdiom) {
            case .pad:
                return 480
            default:
                return 320
            }
        }()

        CalibrationTheme.primaryLabelFont = {
            switch(UIDevice.current.userInterfaceIdiom) {
            case .pad:
                return UIFont(name: "Papyrus", size: 144)!
            default:
                return UIFont(name: "Papyrus", size: 96)!
            }
        }()

        CalibrationTheme.secondaryLabelFont = {
            switch(UIDevice.current.userInterfaceIdiom) {
            case .pad:
                return UIFont(name: "Papyrus", size: 60)!
            default:
                return UIFont(name: "Papyrus", size: 40)!
            }
        }()

    }

    public func disable() {
        // TODO: Change the Theme Back?
        enabled = false
    }

}
