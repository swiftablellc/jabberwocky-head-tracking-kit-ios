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

@objc public class ClickAnimator: NSObject {
    
    private var animationDuration: TimeInterval = 0.5
    private var alpha: CGFloat = 0.75
    
    @objc public static let shared = ClickAnimator()
    
    override private init() { }
    
    @objc public func execute(on view: UIView, completion: @escaping () -> ()) {
        
        view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        UIView.animate(withDuration: animationDuration,
            animations: {
                view.alpha = 0.0
        },
            completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    view.alpha = 1.0
                }
        })
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 12.0,
            options: [.allowUserInteraction, .curveLinear],
            animations: {
                view.transform = .identity
        },
            completion: { _ in completion() }
        )
    }
}
