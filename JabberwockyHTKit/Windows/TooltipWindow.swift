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

@objc public class TooltipWindow: HTGlassWindow {
    let tooltipView: TooltipGlassView = TooltipGlassView()
    
    @objc override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(tooltipView)
        
        tooltipView.translatesAutoresizingMaskIntoConstraints = false
        tooltipView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        tooltipView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        tooltipView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tooltipView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Setting window level manually caps out at 10 million which is below system keyboard
    //But overriding the property works...
    @objc public override var windowLevel: UIWindow.Level {
        get {
            return HTWindows.tooltipWindowLevel
        }
        set {
            //do nothing, this is a fixed value
        }
    }
    
}

