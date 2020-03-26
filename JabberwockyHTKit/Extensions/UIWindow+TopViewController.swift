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

extension UIWindow {

    @objc public var htTopViewController: UIViewController? {
        if var topController = self.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            if let navigationController = topController as? UINavigationController {
                return navigationController.visibleViewController
            } else {
                return topController
            }
        }
        return nil
    }

}
