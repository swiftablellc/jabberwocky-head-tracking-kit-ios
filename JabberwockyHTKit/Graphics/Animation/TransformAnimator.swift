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

import UIKit.UIView

@objc public class TransformAnimator: NSObject {
    private let ANIMATION_DURATION_SECONDS = 0.3
    
    private weak var view: UIView?
    
    private let startTransformFunction: () -> (CGAffineTransform)
    
    private var isShowing: Bool = false
    private var isAnimating: Bool = false
    private var isSkippingAnimation: Bool = false
    
    @objc public enum InProgressFailMode: Int {
        case skipAnimation
        case ignore
    }
    private let failMode: InProgressFailMode
    
    @objc public init(_ view: UIView, failMode: InProgressFailMode = .skipAnimation,
                startTransformFunction: @escaping () -> (CGAffineTransform)) {
        
        self.view = view
        self.failMode = failMode
        self.startTransformFunction = startTransformFunction
    }
    
    @objc public func show() {
        if self.isShowing {
            return
        }
        
        if self.isAnimating {
            //In progress of animating a hide
            switch(failMode) {
            case .skipAnimation:
                self.isShowing = true
                self.isSkippingAnimation = true
                
                self.view?.isHidden = false
                self.view?.transform = CGAffineTransform.identity
            case .ignore:
                break
            }
            
            return
        }
        
        self.isShowing = true
        self.isAnimating = true
        
        self.view?.isHidden = false
        self.view?.transform = self.startTransformFunction()
        
        UIView.animate(
            withDuration: self.ANIMATION_DURATION_SECONDS,
            animations: {
                self.view?.transform = CGAffineTransform.identity
            },
            completion: {
                _ in
                
                self.isAnimating = false
                self.isSkippingAnimation = false
            }
        )
    }
    
    @objc public func hide(_ didSuccessfullyHideCompletion: @escaping ()->() = {}) {
        if !self.isShowing {
            didSuccessfullyHideCompletion()
            return
        }
        
        if self.isAnimating {
            switch(failMode) {
            case .skipAnimation:
                self.isShowing = false
                self.isSkippingAnimation = true
                
                self.view?.isHidden = true
                self.view?.transform = CGAffineTransform.identity
                didSuccessfullyHideCompletion()
            case .ignore:
                break
            }
            return
        }
        
        self.isAnimating = true
        
        UIView.animate(
            withDuration: self.ANIMATION_DURATION_SECONDS,
            animations: {
                self.view?.transform = self.startTransformFunction()
            },
            completion: {
                _ in
                
                let didSkip = self.isSkippingAnimation
                
                self.isAnimating = false
                self.isSkippingAnimation = false
                
                if !didSkip {
                    self.isShowing = false
                    self.view?.isHidden = true
                    self.view?.transform = CGAffineTransform.identity
                    didSuccessfullyHideCompletion()
                }
            }
        )
    }
}
