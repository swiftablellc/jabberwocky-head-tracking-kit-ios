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

@objc public protocol NotificationBannerDelegate: class {
    func notificationBannerWillAppear(_ banner: BaseNotificationBanner)
    func notificationBannerDidAppear(_ banner: BaseNotificationBanner)
    func notificationBannerWillDisappear(_ banner: BaseNotificationBanner)
    func notificationBannerDidDisappear(_ banner: BaseNotificationBanner)
}

@objc public class BaseNotificationBanner: UIView {

    @objc public static let BannerWillAppear: Notification.Name = Notification.Name(rawValue: "NotificationBannerWillAppear")

    @objc public static let BannerDidAppear: Notification.Name = Notification.Name(rawValue: "NotificationBannerDidAppear")

    @objc public static let BannerWillDisappear: Notification.Name = Notification.Name(rawValue: "NotificationBannerWillDisappear")

    @objc public static let BannerDidDisappear: Notification.Name = Notification.Name(rawValue: "NotificationBannerDidDisappear")

    @objc public static let BannerObjectKey: String = "NotificationBannerObjectKey"

    @objc public static let BANNER_DEFAULT_HEIGHT: CGFloat = 50.0

    @objc public weak var delegate: NotificationBannerDelegate?

    @objc public var bannerHeight: BannerHeight {
        get {
            return BannerHeight(contentHeight: customBannerHeight, adjustForNotch: shouldAdjustForNotchFeaturedIphone)
        }
    }

    @objc public internal(set) var titleLabel: UILabel?

    @objc public var duration: TimeInterval = 5.0

    @objc public var autoDismiss: Bool = true {
        didSet {
            if !autoDismiss {
                dismissOnTap = false
                dismissOnSwipeUp = false
            }
        }
    }

    @objc public var dismissOnTap: Bool = true

    @objc public var dismissOnSwipeUp: Bool = true

    @objc public var onTap: (() -> Void)?

    @objc public var onSwipeUp: (() -> Void)?

    @objc public var bannerQueue: NotificationBannerQueue = NotificationBannerQueue.default

    @objc public var dismissDuration: TimeInterval = 0.5

    @objc public private(set) var isDisplaying: Bool = false

    @objc public private(set) var isAnimating: Bool = false

    internal var contentView: UIView!

    internal var spacerView: UIView!

    internal var spacerHeightViewConstraint: NSLayoutConstraint?

    internal var padding: CGFloat = 15.0

    internal weak var bannerParentViewController: UIViewController?

    internal var customBannerHeight: CGFloat = BaseNotificationBanner.BANNER_DEFAULT_HEIGHT

    var isSuspended: Bool = false

    private(set) var bannerPosition: BannerPosition!

    private var bannerPositionFrame: BannerPositionFrame!

    private var notificationUserInfo: [String: BaseNotificationBanner] {
        return [BaseNotificationBanner.BannerObjectKey: self]
    }

    @objc public override var backgroundColor: UIColor? {
        get {
            return contentView.backgroundColor
        } set {
            contentView.backgroundColor = newValue
            spacerView.backgroundColor = newValue
        }
    }

    init(style: BannerStyle, colors: BannerColorsProtocol? = nil) {
        super.init(frame: .zero)

        spacerView = UIView()
        addSubview(spacerView)

        contentView = UIView()
        addSubview(contentView)

        if let colors = colors {
            backgroundColor = colors.color(for: style)
        } else {
            backgroundColor = BannerColors().color(for: style)
        }

        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeUpGestureRecognizer))
        swipeUpGesture.direction = .up
        addGestureRecognizer(swipeUpGesture)
    }

    @objc required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    internal func createBannerConstraints(for bannerPosition: BannerPosition) {
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        if bannerPosition == .top {
            spacerView.topAnchor.constraint(equalTo: self.topAnchor, constant: -10).isActive = true
        } else {
            spacerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 10).isActive = true
        }
        spacerView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        spacerView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        updateSpacerViewHeight()

        contentView.translatesAutoresizingMaskIntoConstraints = false
        if bannerPosition == .top {
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        } else {
            contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        }

        contentView.heightAnchor.constraint(equalToConstant: bannerHeight.contentHeight).isActive = true
        contentView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

    }

    private func updateSpacerViewHeight() {
        let finalHeight: CGFloat = DeviceTypeUtilities.isNotchFeaturedIPhone()
                && UIApplication.shared.statusBarOrientation.isPortrait
                && (bannerParentViewController?.navigationController?.isNavigationBarHidden ?? true) ? 40.0 : 10.0
        if let spacerHeightViewConstraint = spacerHeightViewConstraint {
            spacerHeightViewConstraint.constant = finalHeight
        } else {
            spacerHeightViewConstraint = spacerView.heightAnchor.constraint(equalToConstant: finalHeight)
            spacerHeightViewConstraint?.isActive = true
        }
    }

    @objc public func dismiss() {

        guard isDisplaying && !isAnimating else {
            return
        }

        NSObject.cancelPreviousPerformRequests(withTarget: self,
                selector: #selector(dismiss),
                object: nil)

        NotificationCenter.default.post(name: BaseNotificationBanner.BannerWillDisappear, object: self, userInfo: notificationUserInfo)
        delegate?.notificationBannerWillDisappear(self)

        UIView.animate(withDuration: dismissDuration, animations: {
            self.frame = self.bannerPositionFrame.startFrame
            self.isAnimating = true
        }) { (completed) in
            self.removeFromSuperview()
            self.isDisplaying = false
            self.isAnimating = false

            NotificationCenter.default.post(name: BaseNotificationBanner.BannerDidDisappear, object: self, userInfo: self.notificationUserInfo)
            self.delegate?.notificationBannerDidDisappear(self)

            self.bannerQueue.showNext()
        }
    }

    @objc public func remove() {

        guard !isDisplaying else {
            return
        }

        bannerQueue.removeBanner(self)
    }

    @objc public func show(queuePosition: QueuePosition = .back,
                     bannerPosition: BannerPosition = .top,
                     queue: NotificationBannerQueue = NotificationBannerQueue.default,
                     on viewController: UIViewController? = nil) {
        bannerParentViewController = viewController
        bannerQueue = queue
        show(placeOnQueue: true, queuePosition: queuePosition, bannerPosition: bannerPosition)
    }

    func show(placeOnQueue: Bool,
              queuePosition: QueuePosition = .back,
              bannerPosition: BannerPosition = .top) {
        
        guard let appWindow: UIWindow = UIApplication.shared.delegate?.window ?? nil else { return }

        guard !isDisplaying else {
            return
        }

        if bannerPositionFrame == nil {
            self.bannerPosition = bannerPosition
            createBannerConstraints(for: bannerPosition)
            bannerPositionFrame = BannerPositionFrame(bannerPosition: bannerPosition,
                    bannerWidth: appWindow.frame.width,
                    bannerHeight: bannerHeight.totalHeight,
                    maxY: maximumYPosition())
        }

        NotificationCenter.default.removeObserver(self,
                name: UIDevice.orientationDidChangeNotification,
                object: nil)
        NotificationCenter.default.addObserver(self,
                selector: #selector(onOrientationChanged),
                name: UIDevice.orientationDidChangeNotification,
                object: nil)

        if placeOnQueue {
            bannerQueue.addBanner(self, queuePosition: queuePosition)
        } else {
            self.frame = bannerPositionFrame.startFrame

            if let bannerParentViewController = bannerParentViewController {
                bannerParentViewController.view.addSubview(self)
            } else {
                appWindow.addSubview(self)
            }

            NotificationCenter.default.post(name: BaseNotificationBanner.BannerWillAppear, object: self, userInfo: notificationUserInfo)
            delegate?.notificationBannerWillAppear(self)

            self.isDisplaying = true
            self.isAnimating = true

            UIView.animate(withDuration: 0.5,
                    delay: 0.0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1,
                    options: .curveLinear,
                    animations: {
                        //BannerHapticGenerator.generate(self.haptic)
                        self.frame = self.bannerPositionFrame.endFrame
                    }) { (completed) in
                self.isAnimating = false
                NotificationCenter.default.post(name: BaseNotificationBanner.BannerDidAppear, object: self, userInfo: self.notificationUserInfo)
                self.delegate?.notificationBannerDidAppear(self)

                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTapGestureRecognizer))
                self.addGestureRecognizer(tapGestureRecognizer)

                /* We don't want to add the selector if another banner was queued in front of it
                   before it finished animating or if it is meant to be shown infinitely
                */
                if !self.isSuspended && self.autoDismiss {
                    self.perform(#selector(self.dismiss), with: nil, afterDelay: self.duration)
                }
            }
        }
    }

    func suspend() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(dismiss), object: nil)
        isSuspended = true
        isDisplaying = false
    }

    func resume() {
        if autoDismiss {
            self.perform(#selector(dismiss), with: nil, afterDelay: self.duration)
            isSuspended = false
            isDisplaying = true
        }
    }

    @objc private dynamic func onOrientationChanged() {
        updateSpacerViewHeight()
        
        guard let appWindow: UIWindow = UIApplication.shared.delegate?.window ?? nil else { return }

        let newY = (bannerPosition == .top) ? (frame.origin.y) : (appWindow.frame.height - bannerHeight.totalHeight)
        frame = CGRect(x: frame.origin.x,
                y: newY,
                width: appWindow.frame.width,
                height: bannerHeight.totalHeight)

        bannerPositionFrame = BannerPositionFrame(bannerPosition: bannerPosition,
                bannerWidth: appWindow.frame.width,
                bannerHeight: bannerHeight.totalHeight,
                maxY: maximumYPosition())
    }

    @objc private dynamic func onTapGestureRecognizer() {
        if dismissOnTap {
            dismiss()
        }

        onTap?()
    }

    @objc private dynamic func onSwipeUpGestureRecognizer() {
        if dismissOnSwipeUp {
            dismiss()
        }

        onSwipeUp?()
    }

    private func maximumYPosition() -> CGFloat {
        if let bannerParentViewController = bannerParentViewController {
            return bannerParentViewController.view.frame.height
        } else {
            guard let appWindow: UIWindow = UIApplication.shared.delegate?.window ?? nil else { return 0 }
            return appWindow.frame.height
        }
    }

    internal func shouldAdjustForNotchFeaturedIphone() -> Bool {
        return DeviceTypeUtilities.isNotchFeaturedIPhone()
                && UIApplication.shared.statusBarOrientation.isPortrait
                && (self.bannerParentViewController?.navigationController?.isNavigationBarHidden ?? true)
    }

}
