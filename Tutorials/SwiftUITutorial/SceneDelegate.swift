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
import JabberwockyARKitEngine
import JabberwockyHTKit
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        if let windowScene = scene as? UIWindowScene {
            HeadTracking.ifConfiguredElse(configuredCompletion: { ht in
                ht.windowScene = windowScene
                ht.enable()
            }) {
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    if (granted) {
                        // Configure the default HTFeatures and enable Head Tracking
                        DispatchQueue.main.async {
                            HeadTracking.configure(withEngine: ARKitHTEngine.self)
                            HeadTracking.shared.windowScene = windowScene
                            HeadTracking.shared.enable()
                        }
                    } else {
                        NSLog("Head Tracking requires camera access.")
                    }
                }
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if let _ = scene as? UIWindowScene {
            HeadTracking.ifConfigured { ht in ht.disable() }
        }
    }

}

