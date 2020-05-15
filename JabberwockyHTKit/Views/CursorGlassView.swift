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

class CursorGlassView: HTGlassView {

    private var cursor: Cursor

    required init(coder decoder: NSCoder) {
        fatalError(" does not support NSCoding (Serialization)...")
    }
    
    init() {
        self.cursor = Cursor()
        cursor.pulsator = Pulsator(numPulse: 3.0, animationDuration: 1.25)
        super.init(frame: CGRect.zero)
        initialize()
    }

    func initialize() {
        // CGFloat(Float) Reason -- CoreAnimation: zPosition should be within (-FLT_MAX, FLT_MAX) range.
        cursor.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        layer.addSublayer(cursor)
        self.alpha = 0
    
        NotificationCenter.default.addObserver(
                self, selector: #selector(self.onCursorUpdateNotification(_:)),
                name: .htOnCursorUpdateNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(
                self, name: .htOnCursorUpdateNotification, object: nil)
    }

    @objc func onCursorUpdateNotification(_ notification: NSNotification) {
        if let cursorContext = notification.userInfo?[NSNotification.htCursorContextKey] as? HTCursorContext {
            drawCursor(cursorContext)
        }
    }

    func drawCursor(_ cursorContext: HTCursorContext) {
        let cursorGraphic = HTCursor.shared.currentCursorGraphic
        self.alpha = HTCursor.shared.alpha
            
        switch(HeadTracking.shared.settings.cursorGraphicsMode) {
        case .Highlight:
            cursor.shadowBlack.isHidden = false
            cursor.shadowWhite.isHidden = false
            
            cursor.clickCursor.isHidden = true
            cursor.scrollCursor.isHidden = true
            cursor.clickAndScrollCursor.isHidden = true
            cursor.zoomInCursor.isHidden = true
            cursor.zoomOutCursor.isHidden = true
            cursor.zoomNoneCursor.isHidden = true
            cursor.emptyCursor.isHidden = true
        case .Classic:
            cursor.shadowBlack.isHidden = true
            cursor.shadowWhite.isHidden = true
            
            cursor.clickCursor.isHidden = cursorGraphic != .click
            cursor.scrollCursor.isHidden = cursorGraphic != .scroll
            cursor.clickAndScrollCursor.isHidden = cursorGraphic != .clickAndScroll
            cursor.zoomInCursor.isHidden = cursorGraphic != .zoomIn
            cursor.zoomOutCursor.isHidden = cursorGraphic != .zoomOut
            cursor.zoomNoneCursor.isHidden = cursorGraphic != .zoomNone
            cursor.emptyCursor.isHidden = cursorGraphic != .empty
        }

        cursor.pulseDelayTimer.update(cursorContext.secondsSinceLastInstance,
                increaseCondition: { cursorContext.isOnEdge })
        if cursor.pulseDelayTimer.isFull {
            cursor.pulsator?.pulseIfCharged()
        }

        updateCursorPositionWithoutAnimation(cursor, cursorContext.convertToPosition(inView: self))
    }

    func updateCursorPositionWithoutAnimation(_ cursor: CALayer, _ newPosition: CGPoint?) {
        if let newPosition = newPosition {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            cursor.position = newPosition
            CATransaction.commit()
        }
        else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            cursor.position = CGPoint.zero
            CATransaction.commit()
        }
    }

}
