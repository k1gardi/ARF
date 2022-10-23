//
//  PlacementView.swift
//  ARF
//
//  Created by Kaewan Gardi on 10/17/22.
//

import SwiftUI

struct PlacementView: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    
    
    var body: some View {
        
        HStack {
            Spacer()
            
            PlacementButton(systemIconName: "xmark.circle.fill", action: {
                print("Cancel placement button pressed.")
                self.placementSettings.selectedModel = nil
            })
            
            Spacer()
            
            PlacementButton(systemIconName: "checkmark.circle.fill", action: {
                print("Confirm plancement button pressed.")
                
                let modelAnchor = ModelAnchor(model: self.placementSettings.selectedModel!, anchor: nil)
                self.placementSettings.modelsConfirmedForPlacement.append(modelAnchor)
                
                self.placementSettings.selectedModel = nil
            })
            
            Spacer()
        }
        .padding(.bottom, 30)
    }
}

struct PlacementButton: View {
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
