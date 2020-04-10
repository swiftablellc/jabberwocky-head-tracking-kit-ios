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

import UIKit

extension UIScrollView {

    var htCanScrollHorizontal: Bool {
        return contentSize.width > frame.width
    }
    var htCanScrollVertical: Bool {
        return contentSize.height > frame.height
    }
    var htCanScrollUp: Bool {
        return htCanScrollVertical && contentOffset.y > 0 - adjustedContentInset.top
    }
    var htCanScrollDown: Bool {
        return htCanScrollVertical && contentOffset.y < contentSize.height - frame.height + adjustedContentInset.bottom
    }
    var htCanScrollLeft: Bool {
        return htCanScrollHorizontal && contentOffset.x > 0 - adjustedContentInset.left
    }
    var htCanScrollRight: Bool {
        return htCanScrollHorizontal && contentOffset.x < contentSize.width - frame.width + adjustedContentInset.right
    }
    
    func htUpdateScroll(horizontalScrollDelta: CGFloat, verticalScrollDelta: CGFloat) -> (CGFloat, CGFloat) {
        //TODO may want to get rid of this once keyboard visible cancels scroll mode
        if !self.isScrollEnabled {
            return (0, 0)
        }
        
        if horizontalScrollDelta == 0 && verticalScrollDelta == 0 {
            return (0, 0)
        }
        
        UIView.animate(withDuration: 0.01) {
            let indicatorsImageView = self.subviews.last as? UIImageView
            indicatorsImageView?.backgroundColor = ThemeColors.primary
            self.flashScrollIndicators()
        }
        
        let previousContentOffsetX = self.contentOffset.x
        let minX: CGFloat = 0 - adjustedContentInset.left
        let maxX: CGFloat = max(0, self.contentSize.width - self.visibleSize.width + adjustedContentInset.right)
        var newX = previousContentOffsetX + horizontalScrollDelta
        newX = min(maxX.rounded(.towardZero), max(minX.rounded(.towardZero), newX))
        self.contentOffset.x = newX

        let previousContentOffsetY = self.contentOffset.y
        let minY: CGFloat = 0 - adjustedContentInset.top
        let maxY = max(0, self.contentSize.height - self.visibleSize.height + adjustedContentInset.bottom)
        var newY = previousContentOffsetY + verticalScrollDelta
        newY = min(maxY.rounded(.towardZero), max(minY.rounded(.towardZero), newY))
        self.contentOffset.y = newY
        
        let actualHorizontalScrollDelta = newX - previousContentOffsetX
        let actualVerticalScrollDelta = newY - previousContentOffsetY
        return (actualHorizontalScrollDelta, actualVerticalScrollDelta)
    }
   
}
