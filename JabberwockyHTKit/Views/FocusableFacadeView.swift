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

    @objc public let focusableDelegate: HTFocusable
    
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
        let delegateFrame = focusableDelegate.htFrameInScreenCoordinates()
        let center = CGPoint(x: delegateFrame.origin.x + delegateFrame.width/2,
                             y: delegateFrame.origin.y + delegateFrame.height/2)
        let height = max(delegateFrame.height, HeadTracking.shared.settings.minimumElementSize)
        let width = max(delegateFrame.width, HeadTracking.shared.settings.minimumElementSize)
        let x = center.x - width / 2
        let y = center.y - height / 2
        self.frame = CGRect(x: x, y: y, width: width, height: height)
    }

    @objc public func screenPointInTargetFrame(_ screenPointInAccessibleFrame: CGPoint) -> CGPoint {
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

}
