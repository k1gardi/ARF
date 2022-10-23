//
//  ARViewContainer.swift
//  ARF
//
//  Created by Kaewan Gardi on 10/22/22.
//

import SwiftUI
import RealityKit
import ARKit

private let anchorNamePrefix = "model-"

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var sessionSettings: SessionSettings
    @EnvironmentObject var sceneManager: SceneManager
    @EnvironmentObject var modelsViewModel: ModelsViewModel
    @EnvironmentObject var modelDeletionManager: ModelDeletionManager

    func makeUIView(context: Context) -> CustomARView {
        let arView = CustomARView(frame: .zero, sessionSettings: sessionSettings, modelDeletionManager: modelDeletionManager)
        
        arView.session.delegate = context.coordinator
        
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
            self.updateScene(for: arView)
            self.updatePersistenceAvailable(for: arView)
            self.handlePersistense(for: arView)
            
        })
        
        return arView
    }
    
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
    private func updateScene(for arView: CustomARView) {
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
        
        if let modelAnchor = self.placementSettings.modelsConfirmedForPlacement.popLast(), let modelEntity = modelAnchor.model.modelEntity {
            
            if let anchor = modelAnchor.anchor {
                // We know this is being loaded from a persisted scene
                self.place(modelEntity, for: anchor, in: arView)
            } else if let transform = getTransformForPlacement(in: arView) {
                // Anchor needs to be created for placement
                let anchorName = anchorNamePrefix + modelAnchor.model.name
                let anchor = ARAnchor(name: anchorName, transform: transform)
                
                self.place(modelEntity, for: anchor, in: arView)
                
                arView.session.add(anchor: anchor)

                self.placementSettings.recentlyPlaced.append(modelAnchor.model)
            }
        }
    }
    
    private func place(_ modelEntity: ModelEntity, for anchor: ARAnchor, in arView: ARView) {
        let clonedEntity = modelEntity.clone(recursive: true)
        
        clonedEntity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: clonedEntity)
        
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)
        
        anchorEntity.anchoring = AnchoringComponent(anchor)
        
        arView.scene.addAnchor(anchorEntity)
        
        self.sceneManager.anchorEntities.append(anchorEntity)
        
        print("Added modelEntity to scene.")
    }
    
    private func getTransformForPlacement(in arView: ARView) -> simd_float4x4? {
        guard let query = arView.makeRaycastQuery(from: arView.center, allowing: .estimatedPlane, alignment: .any)
        else {
            return nil
        }
        
        guard let raycastResult = arView.session.raycast(query).first else { return nil }
        
        return raycastResult.worldTransform
    }
}


// MARK: - Persistence

class SceneManager: ObservableObject {
    @Published var isPersistenceAvailable: Bool = false
    @Published var anchorEntities: [AnchorEntity] = []
    
    var shouldSaveSceneToFilesystem: Bool = false
    var shouldLoadSceneFromFilesystem: Bool = false
    
    lazy var persistenceUrl: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil,
                                               create: true).appendingPathComponent("arf.persistence")
        } catch {
            fatalError("Unable to get persistenceUrl: \(error.localizedDescription)")
        }
    }()
    
    var scenePersistenceData: Data? {
        return try? Data(contentsOf: persistenceUrl)
    }
    
}

extension ARViewContainer {
    
    private func updatePersistenceAvailable(for arView: ARView) {
        guard let currentFrame = arView.session.currentFrame else {
            print("ARFrame not available.")
            return
        }
        
        switch currentFrame.worldMappingStatus {
        case .mapped, .extending:
            self.sceneManager.isPersistenceAvailable = !self.sceneManager.anchorEntities.isEmpty
        default:
            self.sceneManager.isPersistenceAvailable = false
        }
    }
    
    private func handlePersistense(for arView: CustomARView) {
        if self.sceneManager.shouldSaveSceneToFilesystem {
            ScenePersistenceHelper.saveScene(for: arView, at: self.sceneManager.persistenceUrl)
            
            self.sceneManager.shouldSaveSceneToFilesystem = false
        } else if self.sceneManager.shouldSaveSceneToFilesystem {
            
            guard let scenePersistenceData = self.sceneManager.scenePersistenceData else {
                print("Unable to retrieve scenePersistenceData. Cancelled loadScene operation.")
                
                self.sceneManager.shouldLoadSceneFromFilesystem = false
                return
            }
            
            self.modelsViewModel.clearModelEntitiesFromMemory()
            self.sceneManager.anchorEntities.removeAll(keepingCapacity: true)
            ScenePersistenceHelper.loadScene(for: arView, with: scenePersistenceData)
            self.sceneManager.shouldLoadSceneFromFilesystem = false
        }
    }
}


// MARK: ARSessionDelegate + Coordinator

extension ARViewContainer {
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                if let anchorName = anchor.name, anchorName.hasPrefix(anchorNamePrefix) {
                    let modelName = anchorName.dropFirst(anchorNamePrefix.count)
                    
                    print("ARSession: didAdd anchor from modelName: \(modelName)")
                    
                    guard let model = self.parent.modelsViewModel.models.first(where: { $0.name == modelName })
                    else {
                        print("Unable to retrieve model from modelsViewModel.")
                        return
                    }
                    
                    if model.modelEntity == nil {
                        model.asyncLoadModelEntity { completed, error in
                            if completed {
                                let modelAnchor = ModelAnchor(model: model, anchor: anchor)
                                self.parent.placementSettings.modelsConfirmedForPlacement.append(modelAnchor)
                                print("Adding modelAnchor with name: \(model.name)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
