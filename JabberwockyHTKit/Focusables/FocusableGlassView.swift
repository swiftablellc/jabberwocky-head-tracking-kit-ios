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

class FocusableGlassView: UIView {
    
    // TODO: This should probably be Focusable: FocusableFacadeView or some other mechanism,
    // but the Focusable protocol can't extend the Hashable protocol without causing other problems.
    var focusableViewMap: [UIView: FocusableFacadeView] = [:]

    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Focusable glass views cannot be interacted with.  Always pass hit tests through...
        return nil
    }
    
    func collectFocusableViews(_ focusableViews: [UIView]) {
        // remove focusableViews that are not in the new action target set
        for focusableView in focusableViewMap.keys {
            if !focusableViews.contains(focusableView) {
                // Don't want to remove facade views that are currently doing click animations
                if let facadeView = focusableViewMap[focusableView], facadeView.isDisposable {
                    facadeView.removeFromSuperview()
                    focusableViewMap[focusableView] = nil
                }
            }
        }

        // Add new focusable views if they do not already exist in the focusable view dictionary
        // create its facade view and add it to the glass view's subviews.
        for focusableView in focusableViews {
            if !focusableViewMap.keys.contains(focusableView), let focusable = focusableView as? HTFocusable {
                let focusableFacadeView = FocusableFacadeView(focusable)
                self.addSubview(focusableFacadeView)
                focusableViewMap[focusableView] = focusableFacadeView
            } else {
                // Update the facade frame if the focusable is already in the map.
                focusableViewMap[focusableView]?.updateFacadeFrame()
            }
        }
    }
    
    func getFocusedFacadeView(at point: CGPoint) -> FocusableFacadeView? {

        var hits = [FocusableFacadeView]()
        // Aggregate all facade views that have overlap with this point
        for focusableFacadeView in focusableViewMap.values {
            let convertedPoint = convert(point, to: focusableFacadeView)
            if focusableFacadeView.point(inside: convertedPoint, with: nil) {
                hits.append(focusableFacadeView)
            }
        }
        
        // Filter out views that cannot be hit tested (not on top), but convert the screen point
        // from the accessible (facade) frame to one that is in the target frame (proportionate).
        hits = hits.filter { focusableFacadeView in
            let targetScreenPoint = focusableFacadeView.screenPointInTargetFrame(from: point)
            // Hit element is expensive... 50+ hit tests is likely to cause poor performance.
            // FIXME: We might want to emit an error or log something here to check for poor performance.
            let hitView = HTFeatureUtils.getHitElement(at: targetScreenPoint, with: SynthFocusHitTestEvent())
            guard let targetView = focusableFacadeView.focusableDelegate as? UIView else { return false }
            guard HTFeatureUtils.isViewEqualOrAncestor(targetView, of: hitView) else { return false }
            return true
        }
        
        // Filter out hits that are not focusable because of cursor mode
        hits = hits.filter { focusableFacadeView in
            return  focusableFacadeView.focusableDelegate.htIgnoresCursorMode() ||
                    HTCursor.shared.actualCursorMode.isClickMode
            
        }
        
        // Filter out hits that are not focusable because of scroll speed
        hits = hits.filter { focusableFacadeView in
            return  focusableFacadeView.focusableDelegate.htIgnoresScrollSpeed() ||
                    !CursorScrollFeature.isScrollingFast
        }

        var closestDistances = (CGFloat.infinity, CGFloat.infinity)
        var closestHit: FocusableFacadeView? = nil
        var isClosestHitInTrueHitBox: Bool = false
        for hit in hits {
            let isHitInTrueHitBox = hit.focusableDelegate.htFrameInScreenCoordinates().contains(point)
            let distances = getDistanceInCloseAndFarDimension(hit.center, point)
            
            if isClosestHitInTrueHitBox && !isHitInTrueHitBox {
                continue
            }
            
            if distances.0 < closestDistances.0 {
                closestDistances = distances
                closestHit = hit
                isClosestHitInTrueHitBox = isHitInTrueHitBox
            } else if distances.0 == closestDistances.0 && distances.1 < closestDistances.1 {
                closestDistances = distances
                closestHit = hit
                isClosestHitInTrueHitBox = isHitInTrueHitBox
            }
        }
        return closestHit
    }
    
    private func getDistanceInCloseAndFarDimension(_ p1: CGPoint, _ p2: CGPoint) -> (CGFloat, CGFloat) {
        let distanceInCloseDimension = min(abs(p1.x - p2.x), abs(p1.y - p2.y))
        let distanceInFarDimension = max(abs(p1.x - p2.x), abs(p1.y - p2.y))
        return (distanceInCloseDimension, distanceInFarDimension)
    }
}
