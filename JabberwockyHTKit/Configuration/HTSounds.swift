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

import AVFoundation

@objc public class HTSounds: NSObject {
    @objc public enum Sound: Int, RawRepresentable {
        case click
        case delete
        case modify
        case beginRecord
        
        public typealias RawValue = String
        
        public var rawValue: RawValue {
            switch self {
            case .click: return "key_press_click"
            case .delete: return "key_press_delete"
            case .modify: return "key_press_modifier"
            case .beginRecord: return "begin_record"
            }
        }
        
        public init?(rawValue: RawValue) {
            switch rawValue {
            case "key_press_click": self = .click
            case "key_press_delete": self = .delete
            case "key_press_modifier": self = .modify
            case "begin_record": self = .beginRecord
            default: return nil
            }
        }
    }
    
    private static var player: AVAudioPlayer?
    
    @objc public static func playSystemSound(_ sound: Sound = .click) {
        DispatchQueue.global(qos: .userInitiated).async {
            if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint {
                print("Silencing secondary audio, will not play system sound")
                return
            }
            
            if AVAudioSession.sharedInstance().isOtherAudioPlaying {
                print("Will not play system sound while other audio is playing")
                return
            }
            
            let directory = "/System/Library/Audio/UISounds"
            let fileName = sound.rawValue
            let url = URL(fileURLWithPath: "\(directory)/\(fileName).caf")
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch {
                print("Failed to play system sound")
            }
        }
    }
    
    @objc public static func playClick() {
        playSystemSound(.click)
    }
}
