//
//  GlobeSceneContainer.swift
//  Roami
//
//  The actual 3D globe, built with SceneKit rather than MapKit — see
//  the discussion in HomeView.swift for why. This wraps an SCNView in
//  SwiftUI, textures a sphere with an Earth image, supports drag-to-
//  rotate with momentum, and reports each pin's current *2D screen
//  position* back up to SwiftUI every frame (via `onPinPositionsUpdate`)
//  so the pin labels can be rendered as real SwiftUI views layered on
//  top of the 3D content, rather than baked into the 3D scene.
//

import SwiftUI
import SceneKit

struct GlobeSceneContainer: UIViewRepresentable {
    let pins: [GlobePin]

    /// Called every frame with each pin's current position in the SCNView's
    /// own coordinate space, plus whether it's currently facing the camera
    /// (so HomeView can fade out labels that have rotated to the far side).
    var onPinPositionsUpdate: (_ positions: [UUID: CGPoint], _ visible: [UUID: Bool]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(pins: pins, onUpdate: onPinPositionsUpdate)
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.scene = context.coordinator.scene
        scnView.delegate = context.coordinator
        scnView.isPlaying = true
        scnView.rendersContinuously = true
        scnView.antialiasingMode = .multisampling4X
        scnView.allowsCameraControl = false // we handle rotation ourselves, drag-only

        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        scnView.addGestureRecognizer(pan)
        context.coordinator.scnView = scnView

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        // Pins can change at runtime (e.g. Home's PIN button showing the
        // user's favorites); sync the scene's marker nodes to match.
        context.coordinator.setPins(pins)
    }

    // MARK: - Coordinator: owns the scene graph, rotation gesture, and per-frame projection

    final class Coordinator: NSObject, SCNSceneRendererDelegate {
        let scene = SCNScene()
        let globeNode = SCNNode()
        weak var scnView: SCNView?

        private var pins: [GlobePin]
        private var pinNodes: [UUID: SCNNode]
        private let onUpdate: (_ positions: [UUID: CGPoint], _ visible: [UUID: Bool]) -> Void

        private var rotationVelocity: CGFloat = 0.15 // radians/sec, gentle idle spin
        private var lastPanTranslation: CGPoint = .zero
        private var lastUpdateTime: TimeInterval = 0

        init(pins: [GlobePin], onUpdate: @escaping (_ positions: [UUID: CGPoint], _ visible: [UUID: Bool]) -> Void) {
            self.pins = pins
            self.onUpdate = onUpdate

            var nodes: [UUID: SCNNode] = [:]
            for pin in pins {
                nodes[pin.id] = Self.makePinMarkerNode(for: pin)
            }
            self.pinNodes = nodes

            super.init()
            buildScene()
        }

        private func buildScene() {
            // Globe sphere, textured with an equirectangular Earth image.
            // Add "earth-texture" (blue marble / stylized, 2:1 aspect ratio,
            // e.g. 2048x1024) to Assets.xcassets.
            let sphere = SCNSphere(radius: 1.0)
            sphere.segmentCount = 96
            let material = SCNMaterial()
            // Fall back to an ocean-blue tint if the texture asset is missing,
            // so the globe never renders as a blank white sphere.
            material.diffuse.contents = UIImage(named: "earth-texture")
                ?? UIColor(red: 0.13, green: 0.35, blue: 0.55, alpha: 1)
            material.specular.contents = UIColor(white: 0.25, alpha: 1)
            material.shininess = 0.1
            sphere.materials = [material]

            let sphereNode = SCNNode(geometry: sphere)
            globeNode.addChildNode(sphereNode)

            for (id, node) in pinNodes {
                globeNode.addChildNode(node)
                _ = id // keys already captured for lookup during projection
            }

            scene.rootNode.addChildNode(globeNode)

            // Lighting: soft ambient fill + a directional "sun" so the sphere reads as 3D.
            let ambient = SCNLight()
            ambient.type = .ambient
            ambient.intensity = 300
            ambient.color = UIColor.white
            let ambientNode = SCNNode()
            ambientNode.light = ambient
            scene.rootNode.addChildNode(ambientNode)

            let sun = SCNLight()
            sun.type = .directional
            sun.intensity = 900
            let sunNode = SCNNode()
            sunNode.light = sun
            sunNode.position = SCNVector3(5, 3, 5)
            sunNode.look(at: SCNVector3Zero)
            scene.rootNode.addChildNode(sunNode)

            // Camera, framing the whole sphere.
            let camera = SCNCamera()
            camera.fieldOfView = 32
            let cameraNode = SCNNode()
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(0, 0, 4.2)
            scene.rootNode.addChildNode(cameraNode)

            // Gentle default tilt, similar to how globes are usually photographed.
            globeNode.eulerAngles = SCNVector3(x: -0.15, y: 0, z: 0)
        }

        private static func makePinMarkerNode(for pin: GlobePin) -> SCNNode {
            let dot = SCNSphere(radius: 0.02)
            dot.materials.first?.diffuse.contents = UIColor.systemRed
            let node = SCNNode(geometry: dot)
            node.position = Self.position(latitude: pin.latitude, longitude: pin.longitude, radius: 1.02)
            return node
        }

        /// Converts lat/long (degrees) to a 3D point on a sphere of the given radius.
        /// NOTE: sign of the z term depends on your texture's UV orientation —
        /// if pins land on the wrong side of the globe from their labels, flip it.
        private static func position(latitude: Double, longitude: Double, radius: Double) -> SCNVector3 {
            let latRad = latitude * .pi / 180
            let lonRad = longitude * .pi / 180
            let x = radius * cos(latRad) * cos(lonRad)
            let y = radius * sin(latRad)
            let z = -radius * cos(latRad) * sin(lonRad)
            return SCNVector3(x, y, z)
        }

        /// Replaces the pin marker nodes when the pin set changes (no-op
        /// when the same pins are passed again on unrelated updates).
        func setPins(_ newPins: [GlobePin]) {
            guard Set(newPins.map(\.id)) != Set(pins.map(\.id)) else { return }

            for node in pinNodes.values {
                node.removeFromParentNode()
            }

            pins = newPins
            var nodes: [UUID: SCNNode] = [:]
            for pin in newPins {
                let node = Self.makePinMarkerNode(for: pin)
                nodes[pin.id] = node
                globeNode.addChildNode(node)
            }
            pinNodes = nodes
        }

        // MARK: Gesture

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let view = gesture.view else { return }
            let translation = gesture.translation(in: view)

            switch gesture.state {
            case .changed:
                let deltaX = Float(translation.x - lastPanTranslation.x)
                let deltaY = Float(translation.y - lastPanTranslation.y)
                globeNode.eulerAngles.y += deltaX * 0.01
                globeNode.eulerAngles.x += deltaY * 0.01
                lastPanTranslation = translation
                rotationVelocity = 0 // user is driving directly; pause idle auto-spin
            case .ended, .cancelled:
                lastPanTranslation = .zero
                rotationVelocity = 0.15 // resume gentle idle spin after user lets go
            default:
                break
            }
        }

        // MARK: SCNSceneRendererDelegate — idle spin + per-frame pin projection

        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            let dt = lastUpdateTime == 0 ? 0 : time - lastUpdateTime
            lastUpdateTime = time

            if rotationVelocity != 0 {
                globeNode.eulerAngles.y += Float(rotationVelocity * dt)
            }

            guard let scnView = scnView else { return }

            var positions: [UUID: CGPoint] = [:]
            var visible: [UUID: Bool] = [:]

            for pin in pins {
                guard let node = pinNodes[pin.id] else { continue }
                let worldPos = node.presentation.worldPosition
                let projected = scnView.projectPoint(worldPos)
                positions[pin.id] = CGPoint(x: CGFloat(projected.x), y: CGFloat(projected.y))

                // Pin faces the camera if it's on the near side of the globe (z < 1 in
                // projected/normalized device space roughly maps to "in front").
                visible[pin.id] = projected.z < 1.0 && Self.isFacingCamera(node: node, cameraZ: 3.4)
            }

            DispatchQueue.main.async { [weak self] in
                self?.onUpdate(positions, visible)
            }
        }

        private static func isFacingCamera(node: SCNNode, cameraZ: Float) -> Bool {
            // Simple near-side test: a point on a sphere centered at the origin
            // is on the visible hemisphere if its world-space Z is positive
            // (camera sits on +Z looking toward the origin).
            node.presentation.worldPosition.z > -0.05
        }
    }
}
