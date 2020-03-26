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

@objc public class FocusableFacadeView: UIView {
    private static let CORNER_RADIUS: CGFloat = 15.0
    private static let BORDER_WIDTH: CGFloat = 3.0
    private static let VIEWING_RECT_SPACING: CGFloat = 3.0
    //This will make viewing rectangles look nice by having some space between them and the element
    private static let VIEWING_RECT_FUDGE_FACTOR: CGFloat =
        2 * ((1 - 0.707) * (CORNER_RADIUS + BORDER_WIDTH) + VIEWING_RECT_SPACING)
    
    private static let VIDEO_PLAYER_BUTTON_CLASS = "AV" + "Button"

    // MARK: Public Fields
    @objc public var isDisposable: Bool {
        // We don't want to remove facade views until they have finished their click animation.
        return _clickAnimationState != .Started
    }
    
    // MARK: Internals
    private enum AnimationState {
        case None
        case Started
        case Completed
    }

    @objc public private(set) var focusableDelegate: HTFocusable
    private var _blurOnComplete = false
    private var _clickAnimationState: AnimationState = .None
    private var _focusAnimationState: AnimationState = .None
    
    public var isFullyFocused: Bool {
        return _focusAnimationState == .Completed
    }
    
    init(_ focusable: HTFocusable) {
        self.focusableDelegate = focusable
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
        self.updateFacadeFrame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     * The Focusable Facade View is always in a Focusable Glass View which takes up the entire window.
     * This means that the frame of the facade view is always in screen coordinates.  This is an
     * assumption that cannot be violated.
     */
    func updateFacadeFrame() {
        // If click animation has started we don't want to change the frame position in the window
        if _clickAnimationState != .Started {
            let delegateFrame = focusableDelegate.htFrameInScreenCoordinates()
            let center = CGPoint(x: delegateFrame.origin.x + delegateFrame.width/2,
                                 y: delegateFrame.origin.y + delegateFrame.height/2)
            let height = max(delegateFrame.height, HeadTracking.shared.settings.minimumElementSize) +
                FocusableFacadeView.VIEWING_RECT_FUDGE_FACTOR
            let width = max(delegateFrame.width, HeadTracking.shared.settings.minimumElementSize) +
                FocusableFacadeView.VIEWING_RECT_FUDGE_FACTOR
            let x = center.x - width / 2
            let y = center.y - height / 2
            self.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }

    func screenPointInTargetFrame(from screenPointInAccessibleFrame: CGPoint) -> CGPoint {
        // Convert screen point into a point in the accessible frame's coordinate system
        let accessiblePoint = self.convert(screenPointInAccessibleFrame, from: nil)
        
        let accessibleWidth = frame.width
        let accessibleHeight = frame.height
        // Scaled X and Y are between 0.0 and 1.0 with respect to the bounds of the accessible frame
        let scaledX = accessiblePoint.x / accessibleWidth
        let scaledY = accessiblePoint.y / accessibleHeight
        
        // Target frame is a rect of the focusable target framed in screen coordinates
        let targetFrameInScreenCoordinates = focusableDelegate.htFrameInScreenCoordinates()
        let targetHeight = targetFrameInScreenCoordinates.height
        let targetWidth = targetFrameInScreenCoordinates.width
        let targetX = targetFrameInScreenCoordinates.minX
        let targetY = targetFrameInScreenCoordinates.minY
        // Return a point inside the target frame (proportional to where it was in the accessible frame)
        // with respect to the screen's coordinate system
        let screenPoint = CGPoint(x: targetX + scaledX * targetWidth, y: targetY + scaledY * targetHeight)
        return screenPoint
    }

    @objc public func htFocus() {
        
        guard _focusAnimationState == .None else {
            return
        }
        _focusAnimationState = .Started
        _blurOnComplete = false
        
        //TODO: Move this animation logic to a graphics animator class
        // Make sure the border of the real frame is clear
        layer.borderColor = ThemeColors.clear.cgColor
        
        let animationView = UIView()
        animationView.backgroundColor = ThemeColors.clear
        animationView.layer.borderColor = ThemeColors.purePurple.cgColor
        animationView.layer.borderWidth = 1.0
        animationView.layer.cornerRadius = FocusableFacadeView.CORNER_RADIUS
        animationView.layer.opacity = 0.3
        self.addSubview(animationView)
        animationView.frame = self.convert(focusableDelegate.htFrameInScreenCoordinates(), from: nil)
        
        let focusDuration = HeadTracking.shared.settings.clickGesture == .Dwell ?
            HTDwellTime.shared.durationSeconds : 0.5
        
        UIView.animate(
            withDuration: focusDuration, delay: 0, options: [.allowUserInteraction, .curveEaseIn],
            animations: {
                animationView.layer.borderWidth = FocusableFacadeView.BORDER_WIDTH
                animationView.layer.borderColor = ThemeColors.purePurple.cgColor
                animationView.layer.opacity = 1.0
                animationView.frame = self.bounds
        },
            completion: { wasCompleted in
                if wasCompleted {
                    self._focusAnimationState = .Completed
                    self.layer.borderColor = ThemeColors.purePurple.cgColor
                    self.layer.borderWidth = FocusableFacadeView.BORDER_WIDTH
                    self.layer.cornerRadius = FocusableFacadeView.CORNER_RADIUS
                }
                else {
                    self._focusAnimationState = .None
                    //Always reset border to clear when focus animation is .None
                    self.layer.borderColor = ThemeColors.clear.cgColor
                }
                animationView.removeFromSuperview()
        })
    }
    
    @objc public func htBlur() {
        // Only blur if the focus animation started or completed
        // *and* the click animation has not started
        if _focusAnimationState != .None && _clickAnimationState != .Started {
            subviews.forEach({ $0.removeFromSuperview() })
            _focusAnimationState = .None
            //Always reset border to clear when focus animation is .None
            layer.borderColor = ThemeColors.clear.cgColor
        } else {
            _blurOnComplete = true
        }
    }

    @objc public func htTargetScreenPoint(_ focusableScreenPoint: CGPoint) -> CGPoint {
        return screenPointInTargetFrame(from: focusableScreenPoint)
    }

    @objc public func htPlayClickSound() {
        var muteSound = false
        //Don't play sounds from video buttons, or hitting "play" may immediately be paused
        if let VideoPlayerButtonClass = NSClassFromString(FocusableFacadeView.VIDEO_PLAYER_BUTTON_CLASS) {
            if let focusableDelegate = focusableDelegate as? UIView {
                if focusableDelegate.isKind(of: VideoPlayerButtonClass) {
                    muteSound = true
                }
            }
        }

        if !muteSound {
            HTSounds.playSystemSound(focusableDelegate.htClickSound)
        }
    }

    @objc public func htAnimateClick() {
        //If a dwell click, focusAnimationState will be .Completed. Reset for next click.
        if HeadTracking.shared.settings.clickGesture == .Dwell {
            _focusAnimationState = .None
            //Always reset border to clear when focus animation is .None
            self.layer.borderColor = ThemeColors.clear.cgColor
        }
        _clickAnimationState = .Started
        ClickAnimator.shared.execute(on: self, completion: {
            self._clickAnimationState = .Completed
            // Blur needs to be called again after the animation has been completed
            // if Head Tracking as been turned off during the animation, or no Head
            // Tracking updates are causing blur for unfocused elements.
            if self._blurOnComplete {
                self.htBlur()
                self._blurOnComplete = false
            }
        })
    }
}
