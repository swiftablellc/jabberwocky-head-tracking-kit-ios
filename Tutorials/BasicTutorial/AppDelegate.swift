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
import JabberwockyHTKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if (granted) {
                // Configure the default HTFeatures and enable Head Tracking
                DispatchQueue.main.async {
                    HeadTracking.configure()
                    HeadTracking.shared.enable()
                }
            } else {
                NSLog("Head Tracking requires camera access.")
            }
        }
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = TutorialController()
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}

class TutorialController: UIViewController {
    
    private let BUTTON_IDLE_TEXT = "Blink or Tap"
    private let BUTTON_ACTION_TEXT = "Button Tapped!"
    
    private var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        button = UIButton()
        button.setTitle(BUTTON_IDLE_TEXT, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 2.0
        // Subclasses of UIControl are automatically configured to emit .touchUpInside
        // events created by the JabberwockyHTKit framework.
        // See: JabberwockyHTKit/Focusables/UIControl+Focusable.swift [htInitiateAction]
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func buttonAction(sender: UIButton!) {
        if button.title(for: .normal) == BUTTON_IDLE_TEXT {
            button.setTitle(BUTTON_ACTION_TEXT, for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.button.setTitle(self.BUTTON_IDLE_TEXT, for: .normal)
            }
        }
    }
}
