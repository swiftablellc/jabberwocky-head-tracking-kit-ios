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

import JabberwockyHTKitCore
import UIKit

@objc public class CursorClickSoundFeature: NSObject, HTFeature {
    
    private let VIDEO_PLAYER_BUTTON_CLASS = "AV" + "Button"
    
    // MARK: Singleton Initialization
    @objc public private(set) static var shared: CursorClickSoundFeature?

    override private init() { }

    @objc public static func configure() -> HTFeature {
        if CursorClickSoundFeature.shared == nil {
            CursorClickSoundFeature.shared = CursorClickSoundFeature()
        }
        return CursorClickSoundFeature.shared!
    }

    // MARK: HTFeature protocol
    @objc public private(set) var enabled = false

    @objc public func enable() {
        enabled = true
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.onClickNotification(_:)),
            name: .htOnCursorClickNotification, object: nil)
    }

    @objc public func disable() {
        enabled = false
        NotificationCenter.default.removeObserver(self, name: .htOnCursorClickNotification, object: nil)
    }

    // MARK: Internal

    @objc func onClickNotification(_ notification: NSNotification) {
        
        guard let focusContext = notification.userInfo?[NSNotification.htFocusContextKey]
            as? HTFocusContext else {
            return
        }
        
        var muteSound = false
        // Don't play sounds from video buttons, or hitting "play" may immediately be paused
        // FIXME: Relocate...
        if let VideoPlayerButtonClass = NSClassFromString(VIDEO_PLAYER_BUTTON_CLASS) {
            if let focusedElement = focusContext.focusedElement as? UIView {
                if focusedElement.isKind(of: VideoPlayerButtonClass) {
                    muteSound = true
                }
            }
        }

        if !muteSound {
            HTSounds.playSystemSound(focusContext.focusedElement.htClickSound)
        }
    }

}
