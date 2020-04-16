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

import ARKit
import JabberwockyHTKitCore

class FaceMeshView: HTGlassView {

    private var meshColor: UIColor
    private var sceneView: ARSCNView!

    private var povCameraTransform: SCNMatrix4?

    required init(coder decoder: NSCoder) {
        fatalError(" does not support NSCoding (Serialization)...")
    }

    init(backgroundColor: UIColor? = nil, meshColor: UIColor? = nil) {
        self.meshColor = meshColor == nil ? ThemeColors.primary : meshColor!
        
        super.init(frame: CGRect.zero)
        
        guard HeadTrackingCore.shared.isAuthorizedOnDevice else { return }
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 0.8

        if let htSceneView = HTWindows.shared.cameraWindow?.cameraViewController?.sceneView {
            sceneView = ARSCNView()
            sceneView.preferredFramesPerSecond = 60
            sceneView.delegate = self
            sceneView.automaticallyUpdatesLighting = true
            sceneView.showsStatistics = false
            sceneView.scene.background.contents = UIColor.clear
            sceneView.backgroundColor = backgroundColor == nil ? UIColor.white : backgroundColor!
            sceneView.layer.cornerRadius = 15.0
            sceneView.clipsToBounds = true

            sceneView.session = htSceneView.session

            self.addSubview(sceneView)
            sceneView.translatesAutoresizingMaskIntoConstraints = false
            sceneView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            sceneView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            sceneView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            sceneView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        }

    }
    
}

extension FaceMeshView: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        //Face Mesh is not supported on simulator
        #if targetEnvironment(simulator)
            return nil
        #else
            guard let device = sceneView.device else { return nil }
            let faceGeometry = ARSCNFaceGeometry(device: device)
            let node = SCNNode(geometry: faceGeometry)
            node.geometry?.firstMaterial?.fillMode = .lines
            node.geometry?.firstMaterial?.diffuse.contents = meshColor
            return node
        #endif
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceGeometry = node.geometry as? ARSCNFaceGeometry,
            let faceAnchor = anchor as? ARFaceAnchor
            else { return }
        
        faceGeometry.update(from: faceAnchor.geometry)
        
        if let povCameraTransform = povCameraTransform {
            let temporaryCameraNode = SCNNode()
            sceneView.pointOfView!.addChildNode(temporaryCameraNode)
            temporaryCameraNode.transform = povCameraTransform
            sceneView.pointOfView?.position = temporaryCameraNode.worldPosition
            sceneView.pointOfView?.orientation = temporaryCameraNode.worldOrientation
            temporaryCameraNode.removeFromParentNode()
        } else {
            if faceAnchor.isTracked {
                let temporaryCameraNode = SCNNode()
                node.addChildNode(temporaryCameraNode)
                temporaryCameraNode.position = SCNVector3(0, 0, 0.25)
                povCameraTransform = temporaryCameraNode.convertTransform(SCNMatrix4Identity, to: sceneView.pointOfView!)
                temporaryCameraNode.removeFromParentNode()
            }
        }
    }
}
