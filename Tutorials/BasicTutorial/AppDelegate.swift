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
    private var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        button = UIButton()
        button.setTitle("Button", for: .normal)
        button.titleLabel?.textColor = UIColor.purple
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func buttonAction(sender: UIButton!) {
      print("Button tapped")
    }
}
