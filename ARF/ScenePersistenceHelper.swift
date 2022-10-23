//
//  ScenePersistenceHelper.swift
//  ARF
//
//  Created by Kaewan Gardi on 10/22/22.
//

import Foundation
import RealityKit
import ARKit

class ScenePersistenceHelper {
    class func saveScene(for arView: CustomARView, at persistenceUrl: URL) {
        print("Save scene to local filesystem.")
        
        arView.session.getCurrentWorldMap { worldMap, error in
            
            guard let map = worldMap else {
                print("Persistence Error: Unable to get worldMap: \(error!.localizedDescription)")
                return
            }
            
            do {
                let sceneData = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                try sceneData.write(to: persistenceUrl, options: [.atomic])
            } catch {
                print("Persistence Error: Unable to save scene to local filesystem: \(error.localizedDescription)")
                
            }
        }
    }
    
    class func loadScene(for arView: CustomARView, with scenePersistenceData: Data) {
        print("Load scene from local filesystem.")
        
        
        let worldMap: ARWorldMap = {
            do {
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: scenePersistenceData) else {
                    fatalError("Persistence Error: No ARWorldMap in archive.")
                }
                
                return worldMap
            } catch {
                fatalError("Persistence Error: Unanble to unarchive ARWorldMap from scencePersistenceData: \(error.localizedDescription)")
            }
        }()
        
        let newConfig = arView.defaultConfiguration
        newConfig.initialWorldMap = worldMap
        arView.session.run(newConfig, options: [.resetTracking, .removeExistingAnchors])
    }
}
