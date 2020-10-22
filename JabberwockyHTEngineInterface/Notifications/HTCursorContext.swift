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

@objc public enum HTViewSide: Int, Codable {
    case bottom, left, right, top
}

@objc public class HTCursorContext: NSObject, Codable {

    @objc public let smoothedScreenPoint: CGPoint
    @objc public let smoothedNormalizedPoint: CGPoint
    
    @objc public let isFaceDetected: Bool
    @objc public let isMovingFast: Bool

    @objc public let instanceTimeInSeconds: CFTimeInterval
    @objc public let lastInstanceTimeInSeconds: CFTimeInterval
    @objc public let secondsSinceLastInstance: CFTimeInterval
    
    public let onEdges: Set<HTViewSide>
    @objc public let isOnEdge: Bool

    public init (isFaceDetected: Bool, isMovingFast: Bool, instanceTimeInSeconds: CFTimeInterval,
                 lastInstanceTimeInSeconds: CFTimeInterval?, smoothedNormalizedPoint: CGPoint?,
                 smoothedScreenPoint: CGPoint?) {
        self.isFaceDetected = isFaceDetected
        self.isMovingFast = isMovingFast
        self.instanceTimeInSeconds = instanceTimeInSeconds
        self.lastInstanceTimeInSeconds = lastInstanceTimeInSeconds ?? 0
        self.secondsSinceLastInstance = self.instanceTimeInSeconds - self.lastInstanceTimeInSeconds
        self.smoothedNormalizedPoint = smoothedNormalizedPoint ?? CGPoint(x: 0, y: 0)
        self.smoothedScreenPoint = smoothedScreenPoint ?? CGPoint(x: 0, y: 0)
        self.onEdges = HTCursorContext.getEdges(self.isFaceDetected, self.smoothedScreenPoint)
        self.isOnEdge = !self.onEdges.isEmpty
    }
    
    private class func getEdges(_ faceDetected: Bool, _ screenPoint: CGPoint) -> Set<HTViewSide> {
        var edges = Set<HTViewSide>()
        if faceDetected {
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
}
