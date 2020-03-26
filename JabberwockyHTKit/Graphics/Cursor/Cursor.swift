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

class Cursor: CALayer {
    var shadowBlack: CALayer
    var shadowWhite: CALayer
    var clickCursor: ImageCursor
    var scrollCursor: ImageCursor
    var clickAndScrollCursor: ImageCursor
    var zoomInCursor: ImageCursor
    var zoomOutCursor: ImageCursor
    var zoomNoneCursor: ImageCursor
    var emptyCursor: ImageCursor
    
    var pulsator: Pulsator? {
        willSet {
            if let pulsator = pulsator { pulsator.removeFromSuperlayer() }
        }
        didSet {
            if let pulsator = pulsator { addSublayer(pulsator) }
        }
    }
    
    let pulseDelayTimer = ChargingTimer(for: 0.5 /*seconds*/, cycle: false)
    
    required init(coder decoder: NSCoder) {
        fatalError("Cursor does not support NSCoding (Serialization)...")
    }
    
    override init() {
        clickCursor = ImageCursor("click")
        scrollCursor = ImageCursor("scroll")
        clickAndScrollCursor = ImageCursor("clickAndScroll")
        zoomInCursor = ImageCursor("zoomIn")
        zoomOutCursor = ImageCursor("zoomOut")
        zoomNoneCursor = ImageCursor("zoomNone")
        emptyCursor = ImageCursor("emptyCursor")
        
        shadowBlack = CALayer()
        shadowWhite = CALayer()
        
        super.init()
        
        do {
            shadowBlack.shadowOffset = .zero
            shadowBlack.shadowColor = UIColor.black.cgColor
            shadowBlack.shadowRadius = 20
            shadowBlack.shadowOpacity = 1
            
            let shadowSize: CGFloat = 20
            let shadowRect = CGRect(x: -shadowSize, y: -shadowSize,
                                    width: shadowSize * 2, height: shadowSize * 2)
            shadowBlack.shadowPath = UIBezierPath(roundedRect: shadowRect,
                                                  cornerRadius: shadowSize).cgPath
        }
        
        do {
            shadowWhite.shadowOffset = .zero
            shadowWhite.shadowColor = UIColor.white.cgColor
            shadowWhite.shadowRadius = 3
            shadowWhite.shadowOpacity = 1
            
            let shadowSize: CGFloat = 10
            let shadowRect = CGRect(x: -shadowSize, y: -shadowSize,
                                    width: shadowSize * 2, height: shadowSize * 2)
            shadowWhite.shadowPath = UIBezierPath(roundedRect: shadowRect,
                                                  cornerRadius: shadowSize).cgPath
        }
        
        self.addSublayer(shadowBlack)
        self.addSublayer(shadowWhite)
        
        self.addSublayer(clickCursor)
        self.addSublayer(scrollCursor)
        self.addSublayer(clickAndScrollCursor)
        self.addSublayer(zoomInCursor)
        self.addSublayer(zoomOutCursor)
        self.addSublayer(zoomNoneCursor)
        self.addSublayer(emptyCursor)
    }
}
