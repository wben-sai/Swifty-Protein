//
//  ContentView.swift
//  swifty-proteins
//
//  Created by XPI-9 on 8/8/2026.
//

import SwiftUI
import SceneKit

struct SceneKitViewCH2: UIViewRepresentable {
    let chemComp: ChemComp
    
       func makeUIView(context: Context) -> SCNView {
           let scnView = SCNView()
           scnView.scene = buildScene()
           scnView.allowsCameraControl = true
           scnView.autoenablesDefaultLighting = true
           scnView.backgroundColor = .black
           return scnView
       }
    
       func updateUIView(_ uiView: SCNView, context: Context) {
           uiView.scene = buildScene()
       }
    
       // MARK: Scene building
    
       private func buildScene() -> SCNScene {
           let scene = SCNScene()
    
           // Only atoms with valid coordinates
           let validAtoms = chemComp.atoms.filter { $0.x != nil && $0.y != nil && $0.z != nil }
    
           // Lookup: atomID -> position, and atomID -> Atom (for color lookups on bonds)
           var positions: [String: SCNVector3] = [:]
           var atomsByID: [String: Atom] = [:]
    
           // Atom spheres
           for atom in validAtoms {
               let position = SCNVector3(Float(atom.x!), Float(atom.y!), Float(atom.z!))
               positions[atom.atomID] = position
               atomsByID[atom.atomID] = atom
    
               let sphere = SCNSphere(radius: 0.35)
               sphere.firstMaterial?.diffuse.contents = color(for: atom.typeSymbol)
    
               let node = SCNNode(geometry: sphere)
               node.position = position
               node.name = atom.atomID
               scene.rootNode.addChildNode(node)
           }
    
           // Bonds
           for bond in chemComp.bonds {
               guard let p1 = positions[bond.atomID1],
                     let p2 = positions[bond.atomID2],
                     let atom1 = atomsByID[bond.atomID1],
                     let atom2 = atomsByID[bond.atomID2] else { continue }
    
               let bondNode = cylinderNode(
                   from: p1, to: p2,
                   order: bond.order,
                   color1: color(for: atom1.typeSymbol),
                   color2: color(for: atom2.typeSymbol)
               )
               scene.rootNode.addChildNode(bondNode)
           }
    
           // Camera
           let cameraNode = SCNNode()
           cameraNode.camera = SCNCamera()
           cameraNode.position = SCNVector3(0, 0, 15)
           scene.rootNode.addChildNode(cameraNode)
    
           return scene
       }
    
       // MARK: Bond geometry
    
       private func cylinderNode(from p1: SCNVector3, to p2: SCNVector3, order: String, color1: UIColor, color2: UIColor) -> SCNNode {
           let parentNode = SCNNode()
    
           let bondCount = cylinderCount(for: order)
           let radius: CGFloat = 0.08
           let gap: Float = 0.06 // visible space between parallel bond lines
           let offsetStep: Float = Float(radius) * 2 + gap
    
           for i in 0..<bondCount {
               var linePos1 = p1
               var linePos2 = p2
    
               if bondCount > 1 {
                   let offsetMagnitude = (Float(i) - Float(bondCount - 1) / 2.0) * offsetStep
                   let perpendicular = perpendicularOffset(from: p1, to: p2, magnitude: offsetMagnitude)
                   linePos1 = SCNVector3(p1.x + perpendicular.x, p1.y + perpendicular.y, p1.z + perpendicular.z)
                   linePos2 = SCNVector3(p2.x + perpendicular.x, p2.y + perpendicular.y, p2.z + perpendicular.z)
               }
    
               let midPoint = SCNVector3(
                   (linePos1.x + linePos2.x) / 2,
                   (linePos1.y + linePos2.y) / 2,
                   (linePos1.z + linePos2.z) / 2
               )
    
               // Half 1: atom1 -> midpoint, colored like atom1
               parentNode.addChildNode(halfCylinder(from: linePos1, to: midPoint, radius: radius, color: color1))
               // Half 2: midpoint -> atom2, colored like atom2
               parentNode.addChildNode(halfCylinder(from: midPoint, to: linePos2, radius: radius, color: color2))
           }
    
           return parentNode
       }
    
       private func halfCylinder(from p1: SCNVector3, to p2: SCNVector3, radius: CGFloat, color: UIColor) -> SCNNode {
           let vector = SCNVector3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z)
           let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
           let midPosition = SCNVector3((p1.x + p2.x) / 2, (p1.y + p2.y) / 2, (p1.z + p2.z) / 2)
    
           let cylinder = SCNCylinder(radius: radius, height: CGFloat(distance))
           cylinder.firstMaterial?.diffuse.contents = color
    
           let node = SCNNode(geometry: cylinder)
           node.position = midPosition
           orient(node, from: p1, to: p2)
           return node
       }
    
       private func orient(_ node: SCNNode, from p1: SCNVector3, to p2: SCNVector3) {
           let vector = SCNVector3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z)
           let up = SCNVector3(0, 1, 0)
    
           let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
           guard length > 0 else { return }
    
           let normalized = SCNVector3(vector.x / length, vector.y / length, vector.z / length)
           let dot = up.x * normalized.x + up.y * normalized.y + up.z * normalized.z
           let angle = acos(max(-1, min(1, dot)))
    
           let cross = SCNVector3(
               up.y * normalized.z - up.z * normalized.y,
               up.z * normalized.x - up.x * normalized.z,
               up.x * normalized.y - up.y * normalized.x
           )
           let crossLength = sqrt(cross.x * cross.x + cross.y * cross.y + cross.z * cross.z)
    
           if crossLength > 0.0001 {
               let axis = SCNVector3(cross.x / crossLength, cross.y / crossLength, cross.z / crossLength)
               node.rotation = SCNVector4(axis.x, axis.y, axis.z, angle)
           } else if dot < 0 {
               node.rotation = SCNVector4(1, 0, 0, Float.pi)
           }
       }
    
       private func perpendicularOffset(from p1: SCNVector3, to p2: SCNVector3, magnitude: Float) -> SCNVector3 {
           let vector = SCNVector3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z)
           let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
           guard length > 0 else { return SCNVector3Zero }
    
           let normalized = SCNVector3(vector.x / length, vector.y / length, vector.z / length)
           var reference = SCNVector3(0, 1, 0)
           if abs(normalized.y) > 0.99 {
               reference = SCNVector3(1, 0, 0)
           }
    
           let perp = SCNVector3(
               normalized.y * reference.z - normalized.z * reference.y,
               normalized.z * reference.x - normalized.x * reference.z,
               normalized.x * reference.y - normalized.y * reference.x
           )
           let perpLength = sqrt(perp.x * perp.x + perp.y * perp.y + perp.z * perp.z)
           guard perpLength > 0 else { return SCNVector3Zero }
    
           return SCNVector3(
               (perp.x / perpLength) * magnitude,
               (perp.y / perpLength) * magnitude,
               (perp.z / perpLength) * magnitude
           )
       }
    
       private func cylinderCount(for order: String) -> Int {
           switch order.uppercased() {
           case "DOUB", "DOUBLE", "2": return 2
           case "TRIP", "TRIPLE", "3": return 3
           default: return 1
           }
       }
    
       // MARK: Coloring
    
       private func color(for symbol: String) -> UIColor {
           switch symbol.uppercased() {
           case "C": return .darkGray
           case "H": return .white
           case "O": return .red
           case "N": return .blue
           case "S": return .yellow
           case "P": return .orange
           default: return .systemPink
           }
       }
}


struct ContentView: View {
    
    var body: some View {
       
        ProteinList()
            .ignoresSafeArea()
    }
}
