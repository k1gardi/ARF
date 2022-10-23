//
//  ControlView.swift
//  ARF
//
//  Created by Kaewan Gardi on 10/16/22.
//

import SwiftUI

enum ControlModes: String, CaseIterable {
    case browse, scene

}

struct ControlView: View {
    @Binding var selectedControlMode: Int
    @Binding var isControlsVisible: Bool
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    
    var body: some View {
        VStack {
            ControlVisibilityToggleButton(isControlsVisible: $isControlsVisible)
            
            Spacer()
            
            if isControlsVisible {
                ControlModePicker(selectedControlMode: $selectedControlMode)
                ControlButtonBar(showBrowse: $showBrowse, showSettings: $showSettings, selectedControlMode: selectedControlMode)
            }
            
        }
    }
}

struct ControlVisibilityToggleButton: View {
    @Binding var isControlsVisible: Bool
    
    var body: some View {
        HStack {
            
            Spacer()
            
            ZStack {
                
                Color.black.opacity(0.25)
                Button(action: {
                    print("Control visibility toggle button pressed")
                    self.isControlsVisible.toggle()
                }, label: {
                    Image(systemName: self.isControlsVisible ? "rectangle" :
                            "slider.horizontal.below.rectangle")
                    .font(.system(size: 25))
                    .foregroundColor(.white)
                    .buttonStyle(PlainButtonStyle())
                })
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8.0)
        }
        .padding(.top, 45)
        .padding(.trailing, 20)
    }
}

struct ControlModePicker: View {
    @Binding var selectedControlMode: Int
    let controlModes = ControlModes.allCases
    
    init(selectedControlMode: Binding<Int>) {
        self._selectedControlMode = selectedControlMode
        
        UISegmentedControl.appearance().selectedSegmentTintColor = .clear
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(displayP3Red: 1.0, green: 0.827, blue: 0, alpha: 1)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        UISegmentedControl.appearance().backgroundColor = UIColor(Color.black.opacity(0.25))

    }
    
    
    var body: some View {
        Picker(selection: $selectedControlMode, label: Text("Select a Control Mode")) {
            ForEach(0..<controlModes.count) { index in
                Text(self.controlModes[index].rawValue.uppercased()).tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(maxWidth: 400)
        .padding(.horizontal, 10)
    }
}

struct ControlButtonBar: View {
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    var selectedControlMode: Int

    var body: some View {
        HStack(alignment: .center) {
            if selectedControlMode == 1 {
                SceneButtons()
            } else {
                BrowseButtons(showBrowse: $showBrowse, showSettings: $showSettings)
            }
        }
        .frame(maxWidth: 500)
        .padding(30)
        .background(Color.black.opacity(0.25))
    }
}

struct BrowseButtons: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool

    var body: some View {
        HStack {
            // Most recent button
            MostRecentlyPlacedButton().hidden(self.placementSettings.recentlyPlaced.isEmpty)
            
            Spacer()
            
            // Browse Button
            ControlButton(systemIconName: "square.grid.2x2") {
                print("Browse Button pressed")
                self.showBrowse.toggle()
            }.sheet(isPresented: $showBrowse, content: {
                BrowseView(showBrowse: $showBrowse)
                    .environmentObject(placementSettings)
            })
            
            
            Spacer()
            
            // Settings Button
            ControlButton(systemIconName: "slider.horizontal.3") {
                print("Settings Button pressed")
                self.showSettings.toggle()
            }.sheet(isPresented: $showSettings) {
                SettingsView(showSettings: $showSettings)
            }
            
        }
    }
}

struct SceneButtons: View {
    @EnvironmentObject var sceneManager: SceneManager
    
    var body: some View {
        
        ControlButton(systemIconName: "icloud.and.arrow.up") {
            print("Save Scene button pressed.")
            self.sceneManager.shouldSaveSceneToFilesystem = true
        }
        .hidden(!self.sceneManager.isPersistenceAvailable)
        
        Spacer()
        
        ControlButton(systemIconName: "icloud.and.arrow.down") {
            print("Load Scene button pressed.")
            self.sceneManager.shouldLoadSceneFromFilesystem = true

        }
        .hidden(self.sceneManager.scenePersistenceData == nil)
        
        Spacer()
        
        ControlButton(systemIconName: "trash") {
            print("Clear Scene button pressed.")
            
            for anchorEntity in self.sceneManager.anchorEntities {
                print("Removing anchorEntity with id: \(String(describing: anchorEntity.anchorIdentifier))")
                anchorEntity.removeFromParent()
            }
            
        }
        
    }

}

struct ControlButton: View {
    let systemIconName: String
    let action: () -> Void
    
    var body: some View {
        
        HStack {
            Button(action: {
                self.action()
            }, label: {
                Image(systemName: systemIconName)
                    .font(.system(size: 35))
                    .foregroundColor(.white)
                    .buttonStyle(PlainButtonStyle())
            })
            .frame(width: 50, height: 50)
            
        }
    }
}
