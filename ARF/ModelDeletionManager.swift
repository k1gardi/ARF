//
//  ModelDeletionManager.swift
//  ARF
//
//  Created by Kaewan Gardi on 10/22/22.
//

import SwiftUI
import RealityKit

class ModelDeletionManager: ObservableObject {
    @Published var entitySelectedForDeletion: ModelEntity? = nil {
        willSet(newValue) {
            if self.entitySelectedForDeletion == nil, let newlySelectedModelEntity = newValue {
                print("Selecting new entitySelectedForDeletion, no prior selection")
                
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                newlySelectedModelEntity.modelDebugOptions = component
            } else if let previouslySelectedModelEntity = self.entitySelectedForDeletion, let newlySelectedModelEntity = newValue {
                print("Selecting new newlySelectedModelEntity, had prior selection.")
                
                previouslySelectedModelEntity.modelDebugOptions = nil
                
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                newlySelectedModelEntity.modelDebugOptions = component
            } else if newValue == nil {
                print("Clearing newlySelectedModelEntity")
                self.entitySelectedForDeletion?.modelDebugOptions = nil
            }
        }
    }
}
