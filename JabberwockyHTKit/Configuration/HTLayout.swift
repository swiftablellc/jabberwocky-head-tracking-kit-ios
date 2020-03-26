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

class HTLayout {
    static let longerDimension: CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
    static let shorterDimension: CGFloat = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
    
    //Will be 60 for iPhone X and scaled based on screen real estate for all devices
    static let defaultButtonSize: CGFloat = round(longerDimension * 60.0 / 812.0)
    
    static let minButtonSpacing: CGFloat = 4
    
    static let minPadding: CGFloat = 5
    static let defaultPadding: CGFloat = 10
    static let largePadding: CGFloat = 20
    
    enum OrientationAndIdiom {
        case landscapePad
        case landscapePhone
        case portraitPad
        case portraitPhone
        case unsupported
    }
    
    //status bar is most reliable way to get correct interface orientation at startup
    static var wasLastOrientationLandscape: Bool = UIApplication.shared.statusBarOrientation.isLandscape
    static var orientationAndIdiom: OrientationAndIdiom {
        get {
            let orientation = UIDevice.current.orientation
            var isLandscape = orientation.isLandscape
            var isPortrait = orientation.isPortrait
            if !isLandscape && !isPortrait {
                isLandscape = wasLastOrientationLandscape
                isPortrait = !isLandscape
                wasLastOrientationLandscape = isLandscape
            }
            
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let isPhone = UIDevice.current.userInterfaceIdiom == .phone
            
            if isLandscape && isPad {
                return .landscapePad
            }
            else if isLandscape && isPhone {
                return .landscapePhone
            }
            else if isPortrait && isPad {
                return .portraitPad
            }
            else if isPortrait && isPhone {
                return .portraitPhone
            }
            else {
                return .unsupported
            }
        }
    }
    static var isLandscape: Bool {
        get {
            switch(orientationAndIdiom) {
            case .landscapePad, .landscapePhone:
                return true
            default:
                return false
            }
        }
    }
    static var isPortrait: Bool {
        get {
            switch(orientationAndIdiom) {
            case .portraitPad, .portraitPhone:
                return true
            default:
                return false
            }
        }
    }
    
    static func special(_ orientationAndIdioms: [OrientationAndIdiom],
                        _ completion: @escaping () -> Void) {
        for orientationAndIdiom in orientationAndIdioms {
            if HTLayout.orientationAndIdiom == orientationAndIdiom {
                completion()
            }
        }
    }
}
