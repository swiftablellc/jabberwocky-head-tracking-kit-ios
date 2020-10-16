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

@available(iOS 11.0, *)
@objc public class FaceMeshWindow: HTGlassWindow {
    
    @objc public let faceMeshView: HTGlassView = FaceMeshView()
    
    @available(iOS 13.0, *)
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    private func initialize() {
        self.addSubview(faceMeshView)
        
        let height = HTLayout.longerDimension / 4
        let width = height / 1.75
        
        faceMeshView.translatesAutoresizingMaskIntoConstraints = false
        faceMeshView.heightAnchor.constraint(equalToConstant: height).isActive = true
        faceMeshView.widthAnchor.constraint(equalToConstant: width).isActive = true
        faceMeshView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        faceMeshView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Setting window level manually caps out at 10 million which is below system keyboard
    //But overriding the property works...
    @objc public override var windowLevel: UIWindow.Level {
        get {
            return HTWindows.faceMeshWindowLevel
        }
        set {
            //do nothing, this is a fixed value
        }
    }

}
