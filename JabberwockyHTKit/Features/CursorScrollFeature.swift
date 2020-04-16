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

import JabberwockyHTKitCore
import UIKit

@objc public enum ScrollDirection: Int {
    case horizontal
    case vertical
}

@objc public class CursorScrollFeature: NSObject, HTFeature {
    
    private static let MAX_SCROLL_VELOCITY: CGFloat = 1.8
    private let MAX_SCROLL_ACCELERATION: CGFloat = MAX_SCROLL_VELOCITY / 2.0
    private let NEUTRAL_SCROLL_ANGLE: CGFloat = 0.4
    private static let SCROLLING_FAST_SPEED_THRESHOLD: CGFloat = 4.0 / 60
    
    private var viewsLastHorizontalScrollSpeed = [UIView:CGFloat]()
    private var viewsLastVerticalScrollSpeed = [UIView:CGFloat]()
    
    private var lastCustomScrollTime: CFTimeInterval? = nil
    private var lastCustomScrollSpeed: CGFloat? = nil
    public var customScrollClosure:
        ((CGPoint, [ScrollDirection], CFTimeInterval, CGFloat?, @escaping (CGFloat) -> ()) -> ()) = {
            _, _, _, _, completion in
            completion(CGFloat.zero)
            return
    }
    
    private var hasRecentlyCustomScrolled: Bool {
        let SHORT_INTERVAL_SECONDS = 0.05
        let now = CACurrentMediaTime()
        return now < (lastCustomScrollTime ?? 0) + SHORT_INTERVAL_SECONDS
    }
    
    @objc public static var isScrollingFast: Bool {
        guard let shared = CursorScrollFeature.shared else {
            return false
        }
        
        let maxHorizontal = shared.viewsLastHorizontalScrollSpeed.values.max() ?? 0
        let maxVertical = shared.viewsLastVerticalScrollSpeed.values.max() ?? 0
        let inJavascript = shared.lastCustomScrollSpeed ?? 0
        let maxSpeed = [maxHorizontal, maxVertical, inJavascript].max() ?? 0
        return maxSpeed > CursorScrollFeature.SCROLLING_FAST_SPEED_THRESHOLD
    }
    
    private var defaultScrollTarget: UIScrollView? {
        // FIXME: using the key window is probably not the best strategy... we may want other windows to scroll
        let targetViewController = UIApplication.shared.keyWindow?.htTopViewController
        
        var defaultScrollTarget: UIScrollView? = nil
        if let scrollTargetOverride = targetViewController?.htDefaultScrollTarget {
            defaultScrollTarget = scrollTargetOverride
        } else if let view = targetViewController?.view {
            // Get all scrollable views from the target view controller
            var scrollViews: [UIScrollView] = view.htGetAllSubviewsOf(type: UIScrollView.self)
            if let scrollView = view as? UIScrollView {
                scrollViews.append(scrollView)
            }
            // Sort by largest rectangle
            let scrollViewsSortedByArea = scrollViews.sorted {
                $0.frame.width * $0.frame.height > $1.frame.width * $1.frame.height
            }
            defaultScrollTarget = scrollViewsSortedByArea.first
        }
        
        return defaultScrollTarget
    }

    // MARK: Singleton Initialization
    @objc public private(set) static var shared: CursorScrollFeature?
    
    override private init() { }
    
    @objc public static func configure() -> HTFeature {
        if CursorScrollFeature.shared == nil {
            CursorScrollFeature.shared = CursorScrollFeature()
        }
        return CursorScrollFeature.shared!
    }
    
    // MARK: HTFeature protocol
    @objc public private(set) var enabled = false

    @objc public func enable() {
        enabled = true
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.onCursorUpdateNotification(_:)),
            name: .htOnCursorUpdateNotification, object: nil)
    }
    
    @objc public func disable() {
        enabled = false
        NotificationCenter.default.removeObserver(
            self, name: .htOnCursorUpdateNotification, object: nil)
    }
    
    @objc func onCursorUpdateNotification(_ notification: NSNotification)  {
        
        guard HTCursor.shared.active else { return }
        
        if !HTCursor.shared.actualCursorMode.isScrollMode {
            CursorScrollFeature.shared?.viewsLastHorizontalScrollSpeed = [:]
            CursorScrollFeature.shared?.viewsLastVerticalScrollSpeed = [:]
            return
        }
        
        guard let cursorContext = notification.userInfo?[NSNotification.htCursorContextKey]
            as? HTCursorContext else {
                return
        }
        
        guard let screenPoint = (cursorContext.smoothedScreenPoint.exists ? cursorContext.smoothedScreenPoint.point: nil) else {
            return
        }

        let secondsElapsed = cursorContext.secondsSinceLastInstance

        var availableDirections: [ScrollDirection] = [.horizontal, .vertical]
        if let element = HTFeatureUtils.getHitElement(at: screenPoint, with: SynthScrollHitTestEvent()) {
            let scrolledDirections = scrollViewHierarchy(
                for: element, using: screenPoint, secondsElapsed: secondsElapsed,
                on: cursorContext.onEdges, permitted: availableDirections)
            availableDirections.removeAll(where: {scrolledDirections.contains($0)})
        }
        
        // TODO: Figure out how to move custom scroll to a new feature
        customScrollClosure(screenPoint, availableDirections, secondsElapsed, lastCustomScrollSpeed, { newSpeed in
            self.lastCustomScrollSpeed = newSpeed
            if newSpeed > 0 {
                self.lastCustomScrollTime = CACurrentMediaTime()
            }
        })
        
        // Temporary hack: don't scroll the default view if we recently scrolled in JS
        // Also, only do default scrolling if the cursor is on the edge of the screen
        if !availableDirections.isEmpty && !hasRecentlyCustomScrolled && cursorContext.onEdges.count > 0 {
            if let scrollTarget = self.defaultScrollTarget {
                let scrolledDirections = scroll(
                    for: scrollTarget, using: screenPoint, secondsElapsed: secondsElapsed,
                    on: cursorContext.onEdges, permitted: availableDirections)
                availableDirections.removeAll(where: {scrolledDirections.contains($0)})
            }
        }
        
        //If we didn't scroll, reset lastScrollSpeeds
        if availableDirections.contains(.horizontal) {
            self.viewsLastHorizontalScrollSpeed = [:]
        }
        if availableDirections.contains(.vertical) {
            self.viewsLastVerticalScrollSpeed = [:]
        }
    }
    
    private func scrollViewHierarchy(
        for element: UIView?, using screenPoint: CGPoint, secondsElapsed: CFTimeInterval,
        on edges: Set<HTViewSide>, permitted directions: [ScrollDirection]) -> [ScrollDirection] {
        
        var availableDirections = directions
        if let scrollTarget = HTFeatureUtils.firstViewOfType(UIScrollView.self, inHierarchyOf: element) {
            var scrolledDirections = scroll(
                for: scrollTarget, using: screenPoint, secondsElapsed: secondsElapsed, on: edges,
                permitted: availableDirections)
            availableDirections.removeAll(where: {scrolledDirections.contains($0)})
            scrolledDirections.append(contentsOf: scrollViewHierarchy(
                for: scrollTarget.superview, using: screenPoint, secondsElapsed: secondsElapsed,
                on: edges, permitted: availableDirections))
            return scrolledDirections
        }
        return []
    }
    
    private func scroll(
        for scrollTarget: UIScrollView, using screenPoint: CGPoint, secondsElapsed: CFTimeInterval,
        on edges: Set<HTViewSide>, permitted directions: [ScrollDirection]) -> [ScrollDirection] {
        
        let scrollVelocities = self.getScrollVelocity(
            for: scrollTarget, using: screenPoint, secondsElapsed: secondsElapsed, on: edges)
        var horizontalScrollVelocity = directions.contains(.horizontal) ? scrollVelocities.x : 0.0
        var verticalScrollVelocity = directions.contains(.vertical) ? scrollVelocities.y : 0.0
        let (actualHorizontalScrollDelta, actualVerticalScrollDelta) = scrollTarget.htUpdateScroll(
            horizontalScrollDelta: horizontalScrollVelocity * CGFloat(secondsElapsed),
            verticalScrollDelta: verticalScrollVelocity * CGFloat(secondsElapsed))
        
        horizontalScrollVelocity = actualHorizontalScrollDelta / CGFloat(secondsElapsed)
        verticalScrollVelocity = actualVerticalScrollDelta / CGFloat(secondsElapsed)
        
        let verticalScrollSpeed = abs(verticalScrollVelocity)
        if verticalScrollSpeed != 0 {
            self.viewsLastVerticalScrollSpeed[scrollTarget] = verticalScrollSpeed
        }
        let horizontalScrollSpeed = abs(horizontalScrollVelocity)
        if horizontalScrollSpeed != 0 {
            self.viewsLastHorizontalScrollSpeed[scrollTarget] = horizontalScrollSpeed
        }
        
        var scrolledDirections: [ScrollDirection] = []
        if verticalScrollVelocity != 0.0 {
            scrolledDirections.append(.vertical)
        }
        if horizontalScrollVelocity != 0.0 {
            scrolledDirections.append(.horizontal)
        }
        return scrolledDirections
    }
    
    private func getScrollVelocity(
        for scrollTarget: UIScrollView, using screenPoint: CGPoint, secondsElapsed: CFTimeInterval,
        on edges: Set<HTViewSide>) -> CGPoint {
        
        let isOnLeftOrRight = edges.contains(.left) || edges.contains(.right)
        let isOnTopOrBottom = edges.contains(.top) || edges.contains(.bottom)
        
        let pointInView = scrollTarget.convert(screenPoint, from: nil)
        
        var verticalVelocity: CGFloat = 0
        if !isOnLeftOrRight && scrollTarget.htCanScrollVertical {
            let y = pointInView.y - scrollTarget.contentOffset.y
            let height = scrollTarget.frame.height
            var angle = ((y / height) - 0.5) * 2
            if angle > NEUTRAL_SCROLL_ANGLE { angle -= NEUTRAL_SCROLL_ANGLE }
            else if angle < -NEUTRAL_SCROLL_ANGLE { angle += NEUTRAL_SCROLL_ANGLE }
            else { angle = 0 }
            angle = angle * (2.0 / (2.0 - 2 * NEUTRAL_SCROLL_ANGLE))
            angle = max(min(angle, 1), -1)
            angle = angle * abs(angle) // Better control of slow scroll but preserves same max speed
            verticalVelocity = angle * CursorScrollFeature.MAX_SCROLL_VELOCITY
            verticalVelocity *= height
            
            let lastVerticalScrollSpeed = self.viewsLastVerticalScrollSpeed[scrollTarget] ?? 0.0
            let maxVelocity = lastVerticalScrollSpeed + MAX_SCROLL_ACCELERATION * height *
                CGFloat(secondsElapsed)
            let minVelocity = -maxVelocity
            verticalVelocity = max(min(verticalVelocity, maxVelocity), minVelocity)
            
            //Can't scroll if fully scrolled
            if verticalVelocity < 0 && !scrollTarget.htCanScrollUp {
                verticalVelocity = 0
            }
            //Can't scroll if fully scrolled
            if verticalVelocity > 0 && !scrollTarget.htCanScrollDown {
                verticalVelocity = 0
            }
        }
        
        var horizontalVelocity: CGFloat = 0
        if !isOnTopOrBottom && scrollTarget.htCanScrollHorizontal {
            let x = pointInView.x - scrollTarget.contentOffset.x
            let width = scrollTarget.frame.width
            var angle = ((x / width) - 0.5) * 2
            if angle > NEUTRAL_SCROLL_ANGLE { angle -= NEUTRAL_SCROLL_ANGLE }
            else if angle < -NEUTRAL_SCROLL_ANGLE { angle += NEUTRAL_SCROLL_ANGLE }
            else { angle = 0 }
            angle = angle * (2.0 / (2.0 - 2 * NEUTRAL_SCROLL_ANGLE))
            angle = max(min(angle, 1), -1)
            angle = angle * abs(angle) // Better control of slow scroll but preserves same max speed
            horizontalVelocity = angle * CursorScrollFeature.MAX_SCROLL_VELOCITY
            horizontalVelocity *= width
            
            let lastHorizontalScrollSpeed = self.viewsLastHorizontalScrollSpeed[scrollTarget] ?? 0.0
            let maxVelocity = lastHorizontalScrollSpeed + MAX_SCROLL_ACCELERATION * width *
                CGFloat(secondsElapsed)
            let minVelocity = -maxVelocity
            horizontalVelocity = max(min(horizontalVelocity, maxVelocity), minVelocity)
            
            //Can't scroll if fully scrolled
            if horizontalVelocity < 0 && !scrollTarget.htCanScrollLeft {
                horizontalVelocity = 0
            }
            //Can't scroll if fully scrolled
            if horizontalVelocity > 0 && !scrollTarget.htCanScrollRight {
                horizontalVelocity = 0
            }
        }
        
        return CGPoint(x: horizontalVelocity, y: verticalVelocity)
    }
    
}
