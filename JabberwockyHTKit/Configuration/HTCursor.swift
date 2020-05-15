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

import CoreGraphics
import Foundation

@objc public enum CursorToggle: Int, RawRepresentable, Codable {
    case click
    case scroll
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .click: return "Click"
        case .scroll: return "Scroll"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "Click": self = .click
        case "Scroll": self = .scroll
        default: return nil
        }
    }
}

@objc public class HTCursor: NSObject {
    
    //MARK: Singleton Initialization
    @objc public private(set) static var shared: HTCursor = HTCursor()

    //_selectedCursorMode is what is chosen by the user but can be overriden if certain views
    //are visible
    private var _selectedCursorMode: CursorMode = .clickAndScroll {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .htOnCursorModeUpdateNotification, object: nil,
                                                userInfo: [NSNotification.htCursorModeKey: self._selectedCursorMode])
            }
        }
    }

    //actualCursorMode is what will actually be shown and applied
    @objc public var actualCursorMode: CursorMode {
        var result: CursorMode = .click
        if HTKeyboard.shared.isVisible {
            result = .click
        } else {
            result = self._selectedCursorMode
        }
        return result
    }
    
    @objc public var currentCursorGraphic: CursorGraphic {
        switch(actualCursorMode) {
        case .click:
            return .click
        case .scroll:
            return .scroll
        case .clickAndScroll:
            return .clickAndScroll
        case .empty:
            return .empty
        }
    }

    @objc public var active = true

    @objc public var alpha: CGFloat {
        return HeadTracking.shared.isEnabled && active ? 1.0 : 0.0
    }
    
    @objc public func toggleCursorMode(_ cursorToggle: CursorToggle) {
        HeadTracking.ifConfigured { headTracking in
            let currentMode = self._selectedCursorMode
            
            let newMode: CursorMode = {
                switch(cursorToggle) {
                case .click:
                    if currentMode == .clickAndScroll { return .scroll }
                    else if currentMode == .scroll { return .clickAndScroll }
                    else if currentMode == .click { return .empty }
                    else if currentMode == .empty { return .click }
                    else { return currentMode }
                case .scroll:
                    if currentMode == .clickAndScroll { return .click }
                    else if currentMode == .click { return .clickAndScroll }
                    else if currentMode == .scroll { return .empty }
                    else if currentMode == .empty { return .scroll }
                    else { return currentMode }
                }
            }()
            
            self._selectedCursorMode = newMode
        }
    }
    
    @objc public func disableScroll() {
        HeadTracking.ifConfigured { headTracking in
            let currentMode = self._selectedCursorMode
            if currentMode == .scroll || currentMode == .clickAndScroll {
                self.toggleCursorMode(.scroll)
            }
        }
    }
    
    @objc public func enableClickAndScroll() {
        HeadTracking.ifConfigured { headTracking in
            self._selectedCursorMode = .clickAndScroll
        }
    }

    //MARK: Internal
    override private init() { }
}

@objc public enum CursorMode: Int, RawRepresentable {
    case click
    case scroll
    case clickAndScroll
    case empty
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .click: return "click"
        case .scroll: return "scroll"
        case .clickAndScroll: return "clickAndScroll"
        case .empty: return "empty"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "click": self = .click
        case "scroll": self = .scroll
        case "clickAndScroll": self = .clickAndScroll
        case "empty": self = .empty
        default: return nil
        }
    }
    
    public var isScrollMode: Bool {
        return self == .scroll || self == .clickAndScroll
    }
    
    public var isClickMode: Bool {
        return self == .click || self == .clickAndScroll
    }
}

@objc public enum CursorGraphic: Int {
    case click
    case scroll
    case clickAndScroll
    case zoomIn
    case zoomOut
    case zoomNone
    case empty
}
