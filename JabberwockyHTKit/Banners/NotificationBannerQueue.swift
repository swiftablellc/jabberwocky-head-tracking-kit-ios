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

@objc public enum QueuePosition: Int {
    case back
    case front
}

open class NotificationBannerQueue: NSObject {

    @objc public static let `default` = NotificationBannerQueue()

    private(set) var banners: [BaseNotificationBanner] = []

    @objc public var numberOfBanners: Int {
        return banners.count
    }

    func addBanner(_ banner: BaseNotificationBanner, queuePosition: QueuePosition) {

        if banners.contains(banner) {
            return
        }

        if queuePosition == .back {
            banners.append(banner)

            if banners.firstIndex(of: banner) == 0 {
                banner.show(placeOnQueue: false, bannerPosition: banner.bannerPosition)
            }

        } else {
            banner.show(placeOnQueue: false, bannerPosition: banner.bannerPosition)

            if let firstBanner = banners.first {
                firstBanner.suspend()
            }

            banners.insert(banner, at: 0)
        }

    }

    func removeBanner(_ banner: BaseNotificationBanner) {

        if let index = banners.firstIndex(of: banner) {
            banners.remove(at: index)
        }
    }

    func showNext() {

        if !banners.isEmpty {
            banners.removeFirst()
        }
        guard let banner = banners.first else {
            return
        }

        if banner.isSuspended {
            banner.resume()
        } else {
            banner.show(placeOnQueue: false)
        }
    }

    @objc public func removeAll() {
        banners.removeAll()
    }
}
