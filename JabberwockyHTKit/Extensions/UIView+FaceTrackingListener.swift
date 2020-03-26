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

@objc public class HeadTrackingListener: NSObject {
    weak var view: UIView?
    var headTrackingUpdateFunction: (UIView) -> ()
    
    @objc public init(_ view: UIView, _ headTrackingUpdateFunction: @escaping (UIView) -> ()) {
        self.view = view
        self.headTrackingUpdateFunction = headTrackingUpdateFunction
        super.init()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(onHeadTrackingUpdate),
            name: .htOnHeadTrackingStatusUpdateNotification, object: nil)
        
        //Initialize to the correct view attributes
        onHeadTrackingUpdate()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .htOnHeadTrackingStatusUpdateNotification, object: nil)
    }
    
    @objc private func onHeadTrackingUpdate() {
        guard let view = view else { return }
        
        headTrackingUpdateFunction(view)
    }
}

extension UIView {
    private struct Props {
        static var htListener: HeadTrackingListener? = nil
    }
    
    @objc public var htListener: HeadTrackingListener? {
        get {
            guard let value = objc_getAssociatedObject(self, &Props.htListener) as? HeadTrackingListener? else {
                    return nil
            }
            return value
        } set {
            return objc_setAssociatedObject(self, &Props.htListener, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
