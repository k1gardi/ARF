//
//  DeletionView.swift
//  ARF
//
//  Created by Kaewan Gardi on 10/22/22.
//

import SwiftUI

struct DeletionView: View {
    @EnvironmentObject var sceneManager: SceneManager
    @EnvironmentObject var modelDeletionManager: ModelDeletionManager
    
    var body: some View {
        HStack {
            Spacer()

            DeletionButton(systemIconName: "xmark.circle.fill") {
                print("Cancel Deletion button pressed.")
                self.modelDeletionManager.entitySelectedForDeletion = nil
            }
            
            Spacer()

            DeletionButton(systemIconName: "trash.circle.fill") {
                print("Confirm Deletion button pressed.")
                
                
                guard let anchor = self.modelDeletionManager.entitySelectedForDeletion?.anchor else {return}
                
                let anchoringIdentifier = anchor.anchorIdentifier
                if let index = self.sceneManager.anchorEntities.firstIndex(where: { $0.anchorIdentifier == anchoringIdentifier }) {
                    print("Deleting anchorEntity with id: \(String(describing: anchoringIdentifier))")
                    self.sceneManager.anchorEntities.remove(at: index)
                }
                
                anchor.removeFromParent()
                self.modelDeletionManager.entitySelectedForDeletion = nil
            }
            
            Spacer()
        }
        .padding(.bottom, 30)
    }
}

struct DeletionButton: View {
    let systemIconName: String
    let action: () -> Void
    
    var body: some View {
        
        Button {
            self.action()
        } label: {
            Image(systemName: self.systemIconName)
                .font(.system(size: 50, weight: .light, design: .default))
                .foregroundColor(.white)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 75, height: 75)
        
        
    }
}

