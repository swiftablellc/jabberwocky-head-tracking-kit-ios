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
MIT License
----------------
The MIT License (MIT)

Copyright (c) 2017 Eduardo Moll

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
 Cannibalized from: https://github.com/egmoll7/EMAlertController
 */

import UIKit

enum HTAlertControllerDimension {
    static let padding: CGFloat = 15.0
    static let buttonHeight: CGFloat = HTLayout.defaultButtonSize
    static let iconHeight: CGFloat = 100.0

    static func width(from size: CGSize) -> CGFloat {
        //Ignore orientation for pads
        var width = HTLayout.shorterDimension * 0.66
        
        HTLayout.special([.landscapePhone, .portraitPhone]) {
            if size.width < size.height {
                width = size.width - 60
            }
            else {
                width = size.width * 0.66
            }
        }
        
        return width
    }
}

@objc public class HTAlertController: UIViewController {

    static let CORNER_RADIUS: CGFloat = 14.0
    
    static let largeFont: UIFont = {
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return UIFont.systemFont(ofSize: 24)
        case .pad:
            return UIFont.systemFont(ofSize: 36)
        default:
            return UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.2)
        }
    }()

    static let mediumFont: UIFont = {
        switch(UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return UIFont.systemFont(ofSize: 20)
        case .pad:
            return UIFont.systemFont(ofSize: 30)
        default:
            return UIFont.systemFont(ofSize: UIFont.systemFontSize)
        }
    }()

    internal var alertViewHeight: NSLayoutConstraint?
    internal var alertViewWidth: NSLayoutConstraint?
    internal var messageTextViewHeightConstraint: NSLayoutConstraint?
    internal var buttonStackViewHeightConstraint: NSLayoutConstraint?
    internal var buttonStackViewWidthConstraint: NSLayoutConstraint?
    internal var scrollViewHeightConstraint: NSLayoutConstraint?
    internal var imageViewHeight: CGFloat = HTAlertControllerDimension.iconHeight
    internal var titleLabelHeight: CGFloat = 20
    internal var messageLabelHeight: CGFloat = 20
    internal var iconHeightConstraint: NSLayoutConstraint?
    internal var heightAnchor: NSLayoutConstraint?
    internal var isLaunch = true

    internal lazy var backgroundView: UIView = {
        let bgView = UIView()
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = .clear
        return bgView
    }()

    internal var alertView: UIView = {
        let alertView = UIView()
        alertView.translatesAutoresizingMaskIntoConstraints = false
        alertView.backgroundColor = .white
        alertView.layer.cornerRadius = CORNER_RADIUS
        alertView.layer.shadowColor = ThemeColors.primaryText.cgColor
        alertView.layer.shadowOpacity = 0.2
        alertView.layer.shadowOffset = CGSize(width: 0, height: 0)
        alertView.layer.shadowRadius = 5
        alertView.clipsToBounds = false
        alertView.layer.masksToBounds = false

        return alertView
    }()

    internal var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    internal var titleLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "alertViewTitleLabel"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = HTAlertController.largeFont.htBold()
        label.textAlignment = .center
        label.textColor = ThemeColors.primaryText
        label.numberOfLines = 2

        return label
    }()

    internal var messageTextView: UITextView = {
        let textView = UITextView()
        textView.accessibilityIdentifier = "alertViewMessageTextView"
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = HTAlertController.mediumFont
        textView.textAlignment = .center
        textView.isEditable = false
        textView.showsHorizontalScrollIndicator = false
        textView.textColor = ThemeColors.primaryText
        textView.backgroundColor = UIColor.clear
        textView.isScrollEnabled = false
        textView.bounces = false

        return textView
    }()

    internal let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal

        return stackView
    }()

    @objc public var iconImage: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            guard let image = newValue else {
                imageViewHeight = 0
                iconHeightConstraint?.constant = imageViewHeight
                return
            }
            (image.size.height > CGFloat(0.0)) ? (imageViewHeight = HTAlertControllerDimension.iconHeight) : (imageViewHeight = 0)
            iconHeightConstraint?.constant = imageViewHeight
        }
    }

    @objc public var titleText: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    @objc public var messageText: String? {
        get {
            return messageTextView.text
        }
        set {
            messageTextView.text = newValue

            guard let _ = newValue, let constraint = messageTextViewHeightConstraint else { return }

            messageLabelHeight = 20.0
            messageTextView.removeConstraint(constraint)
            messageTextViewHeightConstraint = messageTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: messageLabelHeight)
            messageTextViewHeightConstraint?.isActive = true
        }
    }

    @objc public init(icon: UIImage?, title: String?, message: String?) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.modalTransitionStyle = UIModalTransitionStyle.coverVertical

        guard (icon != nil || title != nil || message != nil) else {
            fatalError("HTAlertController must have an icon, a title, or a message to display")
        }

        (icon != nil) ? (iconImage = icon) : (imageViewHeight = 0.0)
        (title != nil) ? (titleLabelHeight = 20) : (titleLabelHeight = 0.0)
        (message != nil) ? (messageLabelHeight = 20) : (messageLabelHeight = 0.0)

        titleText = title
        messageText = message
        messageTextView.isSelectable = false

        setUp()
    }

    @objc public convenience init (title: String?, message: String?) {
        self.init(icon: nil, title: title, message: message)
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public override func viewDidLayoutSubviews() {
        if alertView.frame.height >= UIScreen.main.bounds.height - 80 {
            messageTextView.isScrollEnabled = true
        }

        // This is being called when typing
        if (isLaunch) {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6,
                    initialSpringVelocity: 0.5, options: .curveLinear, animations: {
                let transform = CGAffineTransform(translationX: 0, y: -100)
                self.alertView.transform = transform
                self.isLaunch = false
            }, completion: nil)
        }
    }

    @objc public override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1,
                initialSpringVelocity: 0.5, options: .curveLinear, animations: {
            let transform = CGAffineTransform(translationX: 0, y: 50)
            self.alertView.transform = transform
        }, completion: nil)
    }

    @objc public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        if size.height < size.width {
            alertViewHeight?.constant = size.height - 40
            iconHeightConstraint?.constant = 0
        } else {
            alertViewHeight?.constant = size.height - 80
            iconHeightConstraint?.constant = imageViewHeight
        }

        alertViewWidth?.constant = HTAlertControllerDimension.width(from: size)

        UIView.animate(withDuration: 0.3) {
            self.alertView.updateConstraints()
        }
    }
}

// MARK: - Setup Methods
extension HTAlertController {

    internal func setUp() {
        addConstraints()
    }

    internal func addConstraints() {
        view.addSubview(alertView)
        view.insertSubview(backgroundView, at: 0)

        alertView.addSubview(imageView)
        alertView.addSubview(titleLabel)
        alertView.addSubview(messageTextView)
        alertView.addSubview(buttonStackView)

        // backgroundView Constraints
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        // alertView Constraints
        alertView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: 100).isActive = true
        alertView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        alertViewWidth = alertView.widthAnchor.constraint(equalToConstant: HTAlertControllerDimension.width(from: view.bounds.size))
        alertViewWidth?.isActive = true
        alertViewHeight = alertView.heightAnchor.constraint(lessThanOrEqualToConstant: view.bounds.height - 80)
        alertViewHeight?.isActive = true

        // imageView Constraints
        imageView.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 5).isActive = true
        imageView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: HTAlertControllerDimension.padding).isActive = true
        imageView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -HTAlertControllerDimension.padding).isActive = true
        iconHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: imageViewHeight)
        iconHeightConstraint?.isActive = true

        // titleLabel Constraints
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: HTAlertControllerDimension.padding).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -HTAlertControllerDimension.padding).isActive = true
        titleLabel.sizeToFit()

        // messageLabel Constraints
        messageTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        messageTextView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: HTAlertControllerDimension.padding).isActive = true
        messageTextView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -HTAlertControllerDimension.padding).isActive = true
        messageTextView.sizeToFit()

        // actionStackView Constraints
        buttonStackView.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 8).isActive = true
        buttonStackView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 0).isActive = true
        buttonStackView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: 0).isActive = true
        buttonStackView.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: 0).isActive = true
        buttonStackViewHeightConstraint = buttonStackView.heightAnchor.constraint(equalToConstant: (HTAlertControllerDimension.buttonHeight * CGFloat(buttonStackView.arrangedSubviews.count)))
        buttonStackViewHeightConstraint?.isActive = true
    }
}

extension HTAlertController {
    @objc internal func dismissFromTap() {
        dismiss(animated: true, completion: nil)
    }
}

extension HTAlertController {
    @objc public func addAction(_ action: HTAlertAction) {
        buttonStackView.addArrangedSubview(action)

        if buttonStackView.arrangedSubviews.count > 2 {
            buttonStackView.axis = .vertical
            buttonStackViewHeightConstraint?.constant =
                    HTAlertControllerDimension.buttonHeight * CGFloat(buttonStackView.arrangedSubviews.count)
        } else {
            buttonStackViewHeightConstraint?.constant = HTAlertControllerDimension.buttonHeight
            buttonStackView.axis = .horizontal
        }

        if #available(iOS 11.0, *) {
            if buttonStackView.arrangedSubviews.count == 2 {
                buttonStackView.arrangedSubviews[0].layer.maskedCorners = [.layerMinXMaxYCorner]
                buttonStackView.arrangedSubviews[1].layer.maskedCorners = [.layerMaxXMaxYCorner]
            } else {
                buttonStackView.arrangedSubviews.last?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        }

    }
}

@objc public class HTAlertAction: UIButton {
    
    static let veryLightGray = UIColor(hue: 282.0 / 360.0, saturation: 0.02, brightness: 0.95, alpha: 1)

    @objc public enum HTAlertActionStyle: Int {
        case simple
        case bold
        case danger
    }

    // MARK: - Properties
    internal var action: (() -> Void)?
    internal var style: HTAlertActionStyle = .simple

    var titleFont: UIFont? {
        get {
            return self.titleLabel?.font
        }
        set {
            switch style {
            case .bold:
                self.titleLabel?.font = newValue?.htBold()
            case .simple, .danger:
                self.titleLabel?.font = newValue
            }
        }
    }

    // MARK: - Initializers
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc public init(frame: CGRect, fontColor: UIColor) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        self.tintColor = fontColor
        self.setTitleColor(fontColor, for: .normal)
        
        self.layer.borderColor = HTAlertAction.veryLightGray.cgColor
        self.layer.borderWidth = 1.0
    }

    @objc public convenience init(title: String, style: HTAlertActionStyle = .simple, action: (() -> Void)? = nil) {
        
        let fontColor = (style == .danger) ? UIColor.red : ThemeColors.primaryText
        self.init(frame: .zero, fontColor: fontColor)

        self.style = style
        self.action = action
        self.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        self.setTitle(title, for: .normal)
        self.accessibilityIdentifier = title
        self.titleFont = HTAlertController.mediumFont
        self.clipsToBounds = true
        self.layer.cornerRadius = HTAlertController.CORNER_RADIUS
    }

    @objc func actionTapped(sender: HTAlertAction) {
        self.action?()
    }
}
