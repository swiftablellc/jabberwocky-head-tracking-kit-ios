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

@objc public enum HTViewSide: Int {
    case bottom, left, right, top
}

@objc public class HTCursorContext: NSObject, Codable {
    
    @objc public var smoothedScreenPoint: CGPoint
    @objc public var smoothedNormalizedPoint: CGPoint
    
    @objc public var isFaceDetected: Bool
    @objc public var isMovingFast: Bool

    @objc public func convertToPosition(inView view: UIView) -> CGPoint {
        return view.convert(smoothedScreenPoint, from: nil)
    }

    public var onEdges: Set<HTViewSide> {
        var edges = Set<HTViewSide>()
        if isFaceDetected {
            let screenPoint = smoothedScreenPoint
            if screenPoint.x == UIScreen.main.bounds.width {
                edges.insert(.right)
            }
            if screenPoint.x == 0 {
                edges.insert(.left)
            }
            if screenPoint.y == 0 {
                edges.insert(.top)
            }
            if screenPoint.y == UIScreen.main.bounds.height {
                edges.insert(.bottom)
            }
        }
        return edges
    }

    @objc public var isOnEdge: Bool {
        return !onEdges.isEmpty
    }

    @objc public let instanceTimeInSeconds: CFTimeInterval
    @objc public let lastInstanceTimeInSeconds: CFTimeInterval
    @objc public var secondsSinceLastInstance: CFTimeInterval {
        return instanceTimeInSeconds - lastInstanceTimeInSeconds
    }

    public init (isFaceDetected: Bool, isMovingFast: Bool, instanceTimeInSeconds: CFTimeInterval,
                 lastInstanceTimeInSeconds: CFTimeInterval?, smoothedNormalizedPoint: CGPoint?,
                 smoothedScreenPoint: CGPoint?) {
        self.isFaceDetected = isFaceDetected
        self.isMovingFast = isMovingFast
        self.instanceTimeInSeconds = instanceTimeInSeconds
        self.lastInstanceTimeInSeconds = lastInstanceTimeInSeconds ?? 0
        self.smoothedNormalizedPoint = smoothedNormalizedPoint ?? CGPoint(x: 0, y: 0)
        self.smoothedScreenPoint = smoothedScreenPoint ?? CGPoint(x: 0, y: 0)
        
    }
}
