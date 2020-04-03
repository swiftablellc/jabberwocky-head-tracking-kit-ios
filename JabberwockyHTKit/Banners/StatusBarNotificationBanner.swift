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

/*
Copyright (c) 2017-2018 Daltron <daltonhint4@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

/*
 Cannibalized from: https://github.com/Daltron/NotificationBanner
 */

import UIKit

@objc public class StatusBarNotificationBanner: BaseNotificationBanner {
    
    public static var statusBarFont: UIFont = { () -> UIFont in
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return UIFont.systemFont(ofSize: 12)
        case .pad:
            return UIFont.systemFont(ofSize: 18)
        default:
            return UIFont.systemFont(ofSize: UIFont.systemFontSize * 0.6)
        }
    }().htBold()

    @objc public static let STATUS_BAR_DEFAULT_HEIGHT: CGFloat = 20.0
    @objc public static let STATUS_BAR_VERTICAL_SAFE_INSET: CGFloat = 5.0

    override init(style: BannerStyle, colors: BannerColorsProtocol? = nil) {
        super.init(style: style, colors: colors)
        customBannerHeight = StatusBarNotificationBanner.STATUS_BAR_DEFAULT_HEIGHT

        titleLabel = UILabel()
        titleLabel?.font = StatusBarNotificationBanner.statusBarFont
        titleLabel?.textAlignment = .center
        titleLabel?.textColor = .white
        contentView.addSubview(titleLabel!)

    }

    internal override func createBannerConstraints(for bannerPosition: BannerPosition) {
        super.createBannerConstraints(for: bannerPosition)

        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        titleLabel?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        titleLabel?.heightAnchor.constraint(equalToConstant: self.bannerHeight.contentHeight).isActive = true

        if bannerPosition == .top {
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        } else {
            contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        }
    }

    @objc public convenience init(title: String, style: BannerStyle = .info, colors: BannerColorsProtocol? = nil) {
        self.init(style: style, colors: colors)
        titleLabel?.text = title
    }

    @objc public convenience init(attributedTitle: NSAttributedString, style: BannerStyle = .info, colors: BannerColorsProtocol? = nil) {
        self.init(style: style, colors: colors)
        titleLabel?.attributedText = attributedTitle
    }

    @objc required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
