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

import Foundation

@objc public protocol HTEngine {
    
    @objc init(engineSettings: HTEngineSettings)

    @objc func enable()

    @objc func disable()
    
    @objc var isActivating: Bool { get }
    
    @objc var isEnabled: Bool { get }

    @objc var isAuthorizedOnDevice: Bool { get }

    @objc var isSupportedByDevice: Bool { get }

}
