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

@objc public enum BannerPosition: Int {
    case bottom
    case top
}

@objc public class BannerHeight: NSObject {

    init(contentHeight: CGFloat, adjustForNotch: @escaping () -> Bool) {
        self.contentHeight = contentHeight
        self.adjustForNotch = adjustForNotch
    }
    let adjustForNotch: () -> Bool
    let contentHeight: CGFloat
    var spacerHeight: CGFloat {
        get {
            return adjustForNotch() ? DeviceTypeUtilities.NOTCH_HEIGHT : 0.0
        }
    }
    var totalHeight: CGFloat {
        get {
            return contentHeight + spacerHeight
        }
    }
    var isAdjustingForNotch: Bool {
        get {
            return adjustForNotch()
        }
    }
}

@objc class BannerPositionFrame: NSObject {

    private(set) var startFrame: CGRect!
    private(set) var endFrame: CGRect!

    init(bannerPosition: BannerPosition,
         bannerWidth: CGFloat,
         bannerHeight: CGFloat,
         maxY: CGFloat) {
        super.init()
        self.startFrame = startFrame(for: bannerPosition, bannerWidth: bannerWidth, bannerHeight: bannerHeight, maxY: maxY)
        self.endFrame = endFrame(for: bannerPosition, bannerWidth: bannerWidth, bannerHeight: bannerHeight, maxY: maxY)
    }

    private func startFrame(for bannerPosition: BannerPosition,
                            bannerWidth: CGFloat,
                            bannerHeight: CGFloat,
                            maxY: CGFloat) -> CGRect {
        switch bannerPosition {
        case .bottom:
            return CGRect(x: 0,
                    y: maxY,
                    width: bannerWidth,
                    height: bannerHeight)
        case .top:
            return CGRect(x: 0,
                    y: -bannerHeight,
                    width: bannerWidth,
                    height: bannerHeight)

        }
    }

    private func endFrame(for bannerPosition: BannerPosition,
                          bannerWidth: CGFloat,
                          bannerHeight: CGFloat,
                          maxY: CGFloat) -> CGRect {
        switch bannerPosition {
        case .bottom:
            return CGRect(x: 0,
                    y: maxY - bannerHeight,
                    width: bannerWidth,
                    height: bannerHeight)
        case .top:
            return CGRect(x: 0,
                    y: 0,
                    width: startFrame.width,
                    height: startFrame.height)

        }
    }

}
