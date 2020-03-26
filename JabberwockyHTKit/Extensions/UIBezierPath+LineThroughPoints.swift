/*
Modifications Copyright 2020 Swiftable, LLC. <contact@swiftable.org>

Copyright 2015 DeveloperLx <developerlixian@gmail.com>

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
 Cannibalized from https://github.com/DeveloperLx/LxThroughPointsBezier-Swift
*/

import UIKit

private var _contractionFactor: CGFloat = 0.7

extension UIBezierPath {

    // The curve‘s bend level. The good value is about 0.6 ~ 0.8. The default and recommended value is 0.7.
    var htContractionFactor: CGFloat {
        get {
            return _contractionFactor
        }
        set {
            _contractionFactor = max(0, newValue)
        }
    }

    func htAddBezierThrough(points: [CGPoint]) {
        if points.count < 3 {

            switch points.count {

            case 1:
                addLine(to: points[0])
            case 2:
                addLine(to: points[1])
            default:
                break
            }
            return
        }

        var previousPoint = CGPoint.zero

        var previousCenterPoint = CGPoint.zero
        var centerPoint = CGPoint.zero
        var centerPointDistance = CGFloat()

        var obliqueAngle = CGFloat()

        var previousControlPoint1 = CGPoint.zero
        var previousControlPoint2 = CGPoint.zero
        var controlPoint1 = CGPoint.zero

        for i in 0 ... points.count-1 {

            let pointI = points[i]

            if i > 0 {

                previousCenterPoint = htGetCenterPoint(currentPoint, previousPoint)
                centerPoint = htGetCenterPoint(previousPoint, pointI)
                centerPointDistance = htGetDistanceBetween(previousCenterPoint, centerPoint)
                obliqueAngle = htGetObliqueAngle(centerPoint, previousCenterPoint)

                previousControlPoint2 = CGPoint(x: previousPoint.x - 0.5 * htContractionFactor * centerPointDistance * cos(obliqueAngle), y: previousPoint.y - 0.5 * htContractionFactor * centerPointDistance * sin(obliqueAngle))
                controlPoint1 = CGPoint(x: previousPoint.x + 0.5 * htContractionFactor * centerPointDistance * cos(obliqueAngle), y: previousPoint.y + 0.5 * htContractionFactor * centerPointDistance * sin(obliqueAngle))
            }

            switch i {

            case 1 :
                addQuadCurve(to: previousPoint, controlPoint: previousControlPoint2)
            case 2 ..< points.count - 1 :
                addCurve(to: previousPoint, controlPoint1: previousControlPoint1, controlPoint2: previousControlPoint2)
            case points.count - 1 :
                addCurve(to: previousPoint, controlPoint1: previousControlPoint1, controlPoint2: previousControlPoint2)
                addQuadCurve(to: pointI, controlPoint: controlPoint1)

            default:
                break
            }

            previousControlPoint1 = controlPoint1
            previousPoint = pointI
        }
    }

    func htGetObliqueAngle(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {    //  [-π/2, 3π/2)
        var obliqueRatio: CGFloat = 0
        var obliqueAngle: CGFloat = 0

        if (point1.x > point2.x) {

            obliqueRatio = (point2.y - point1.y) / (point2.x - point1.x)
            obliqueAngle = atan(obliqueRatio)
        }
        else if (point1.x < point2.x) {

            obliqueRatio = (point2.y - point1.y) / (point2.x - point1.x)
            obliqueAngle = CGFloat(Double.pi) + atan(obliqueRatio)
        }
        else if (point2.y - point1.y >= 0) {

            obliqueAngle = CGFloat(Double.pi)/2
        }
        else {
            obliqueAngle = -CGFloat(Double.pi)/2
        }

        return obliqueAngle
    }

    func htGetControlPointForBezier(_ point1: CGPoint, _ point2: CGPoint, _ point3: CGPoint) -> CGPoint {
        return CGPoint(x: (2 * point2.x - (point1.x + point3.x) / 2), y: (2 * point2.y - (point1.y + point3.y) / 2));
    }

    func htGetDistanceBetween(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
        return sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y))
    }

    func htGetCenterPoint(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
        return CGPoint(x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
    }
}
