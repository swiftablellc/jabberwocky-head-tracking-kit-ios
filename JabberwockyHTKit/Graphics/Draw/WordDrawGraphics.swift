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

@objc public class WordDrawGraphics: NSObject {
    private let CURSOR_TRAIL_SIZE = 3
    
    private static let WORD_DRAW_POINT_SAMPLE_RATE = 0.03
    // Time duration is dependent on the sample rate and size
    private let WORD_DRAW_TRAIL_SIZE = Int(1 / WORD_DRAW_POINT_SAMPLE_RATE * 4.0) // 4 Seconds
    private let WORD_DRAW_TRAIL_CHUNK_SIZE = 6
    private let WORD_DRAW_MAX_ALPHA: CGFloat = 0.35
    
    @objc public weak var parentView: UIView?
    
    private var wordDrawMiniTrail = [CAShapeLayer]()
    private var wordDrawHistoryPoints = [CGPoint]()
    private var wordDrawLine: CALayer? = nil
    private var wordDrawSamplingTimer =
        ChargingTimer(for: WORD_DRAW_POINT_SAMPLE_RATE, cycle: false, autoCharge: true)
    
    @objc public init(_ view: UIView) {
        self.parentView = view
        
        for _ in 1...CURSOR_TRAIL_SIZE {
            let trail = CAShapeLayer()
            trail.path = UIBezierPath(roundedRect: CGRect(x: -3, y: -3, width: 6, height: 6), cornerRadius: 3).cgPath
            trail.fillColor = UIColor(hue: 0, saturation: 0, brightness: 0.5, alpha: 0.3).cgColor
            wordDrawMiniTrail.append(trail)
            parentView?.layer.addSublayer(trail)
        }
    }
    
    public func onCursorFocus(_ cursorPoint: CGPoint?, shouldDrawWordTrail: Bool, shouldDrawMiniTrail: Bool) {
        // Handle cursor and mini trail
        for point in wordDrawMiniTrail {
            point.isHidden = !shouldDrawMiniTrail
        }
        
        if let cursorPoint = cursorPoint {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            for index in 1...wordDrawMiniTrail.count-1 {
                wordDrawMiniTrail[index-1].position = wordDrawMiniTrail[index].position
            }
            wordDrawMiniTrail.last?.position = cursorPoint
            CATransaction.commit()
        }
        else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            for trail in wordDrawMiniTrail {
                trail.position = CGPoint.zero
            }
            CATransaction.commit()
        }
        
        // Handle word draw trail
        if (shouldDrawWordTrail) {
            if let cursorPoint = cursorPoint {
                wordDrawSamplingTimer.consumeIfCharged(onConsume: {
                    self.wordDrawHistoryPoints.append(cursorPoint)
                    if self.wordDrawHistoryPoints.count > self.WORD_DRAW_TRAIL_SIZE {
                        self.wordDrawHistoryPoints.removeFirst(self.WORD_DRAW_TRAIL_CHUNK_SIZE)
                    }
                    self.wordDrawLine?.removeFromSuperlayer()
                    self.wordDrawLine = self.constructSmoothedFadingLine(points: self.wordDrawHistoryPoints)
                })
            }
        }
        else {
            wordDrawLine?.removeFromSuperlayer()
            wordDrawHistoryPoints.removeAll()
            wordDrawLine = nil
        }
    }
    
    private func constructSmoothedLine(points: [CGPoint]) -> CALayer? {
        guard points.count > 0 else { return nil }
        let smoothedLine = CAShapeLayer()
        smoothedLine.strokeColor = ThemeColors.darkishPurple.withAlphaComponent(WORD_DRAW_MAX_ALPHA).cgColor
        smoothedLine.fillColor = nil
        smoothedLine.lineWidth = 5
        
        let curve = UIBezierPath()
        curve.htContractionFactor = 0.8
        curve.move(to: points.first!)
        curve.htAddBezierThrough(points: points)
        smoothedLine.path = curve.cgPath
        
        parentView?.layer.addSublayer(smoothedLine)
        return smoothedLine
    }
    
    private func constructSmoothedFadingLine(points: [CGPoint]) -> CALayer? {
        guard points.count > 0 else { return nil }
        let smoothedLine = CALayer()
        
        let chunkCount = WORD_DRAW_TRAIL_SIZE / WORD_DRAW_TRAIL_CHUNK_SIZE
        let alphaFade = WORD_DRAW_MAX_ALPHA / CGFloat(chunkCount / 2)
        var alpha: CGFloat = CGFloat(WORD_DRAW_TRAIL_SIZE - points.count) / CGFloat(WORD_DRAW_TRAIL_CHUNK_SIZE) * alphaFade
        var previousChunkEndPoint = points[0]
        for pointChunk in points.htChunks(WORD_DRAW_TRAIL_CHUNK_SIZE) {
            let smoothedLineChunk = CAShapeLayer()
            smoothedLineChunk.strokeColor = ThemeColors.darkishPurple.withAlphaComponent(alpha).cgColor
            smoothedLineChunk.fillColor = nil
            smoothedLineChunk.lineWidth = 5
            
            let curve = UIBezierPath()
            let curvePoints = [previousChunkEndPoint] + pointChunk
            curve.htContractionFactor = 0.8
            curve.move(to: curvePoints.first!)
            curve.htAddBezierThrough(points: curvePoints)
            smoothedLineChunk.path = curve.cgPath
            smoothedLine.addSublayer(smoothedLineChunk)
            previousChunkEndPoint = pointChunk.last!
            alpha = min(WORD_DRAW_MAX_ALPHA, alpha + alphaFade)
        }
        parentView?.layer.addSublayer(smoothedLine)
        return smoothedLine
    }
}
