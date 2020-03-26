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

import UIKit.UIButton

class CursorToggleButton: UIButton {
    var label = UILabel()
    
    init(_ cursorToggle: CursorToggleView.CursorToggle, title: String, imageName: String) {
        super.init(frame: CGRect.zero)
        
        setTitle(title, for: .normal)
        
        layer.cornerRadius = 14.0
        backgroundColor = ThemeColors.primaryButton
        
        self.htClickSound = .modify
        
        titleEdgeInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
        
        setImage(UIImage(named: imageName), for: .normal)
        imageView?.contentMode = .scaleAspectFit
        
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 10.0
        layer.masksToBounds = false
        
        //Just round the two corners on the right
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        label.font = ThemeFonts.small
        label.textAlignment = .center
        label.textColor = ThemeColors.black
        label.text = title
        label.numberOfLines = 2
        
        label.backgroundColor = ThemeColors.standardBackground//.withAlphaComponent(0.8)
        label.layer.cornerRadius = 14.0
        label.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner,
                                     .layerMinXMaxYCorner, .layerMinXMinYCorner]
        label.layer.masksToBounds = true
        
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
        label.heightAnchor.constraint(equalTo: heightAnchor,
                                      multiplier: 0.5).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: bottomAnchor,
                                   constant: HTLayout.defaultPadding).isActive = true
        
        //Size, and placement needs to be set externally
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
