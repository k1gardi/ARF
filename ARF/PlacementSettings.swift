//
//  PlacementSettings.swift
//  ARF
//
//  Created by Kaewan Gardi on 10/17/22.
//

import SwiftUI
import RealityKit
import Combine
import ARKit

struct ModelAnchor {
    var model: Model
    var anchor: ARAnchor?
}

class PlacementSettings: ObservableObject {
    
    @Published var selectedModel: Model? {
        willSet(newValue) {
            print("Setting selectedModel to \(String(describing: newValue?.name))")
        }
    }
        
    @Published var recentlyPlaced: [Model] = []

    var modelsConfirmedForPlacement: [ModelAnchor] = []
    
    var sceneObserver: Cancellable?
    
}
