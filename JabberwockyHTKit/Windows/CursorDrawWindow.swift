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

@objc public class CursorDrawWindow: HTGlassWindow {
    
    @objc public let cursorView: HTGlassView = CursorGlassView()
    
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
        self.addSubview(cursorView)
        cursorView.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        
        cursorView.translatesAutoresizingMaskIntoConstraints = false
        cursorView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        cursorView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        cursorView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        cursorView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Setting window level manually caps out at 10 million which is below system keyboard
    //But overriding the property works...
    @objc public override var windowLevel: UIWindow.Level {
        get {
            return HTWindows.cursorDrawWindowLevel
        }
        set {
            //do nothing, this is a fixed value
        }
    }
}
