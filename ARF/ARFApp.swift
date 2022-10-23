//
//  ARFApp.swift
//  ARF
//
//  Created by Kaewan Gardi on 10/14/22.
//

import SwiftUI
import Firebase


@main
struct ARFApp: App {
    @StateObject var placementSettings = PlacementSettings()
    @StateObject var sessionSettings = SessionSettings()
    @StateObject var sceneManager = SceneManager()
    @StateObject var modelsViewModel = ModelsViewModel()
    @StateObject var modelDeletionManager = ModelDeletionManager()

    init() {
        FirebaseApp.configure()
        
        // Add anon auth
        Auth.auth().signInAnonymously { authResult, error in
            guard let user = authResult?.user else {
                print("FAILED: Anonymous Authentication with Firebase.")
                return
            }
            
            let uid = user.uid
            print("Firebase: Anonymous user authentication with uid: \(uid)")
            
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(placementSettings)
                .environmentObject(sessionSettings)
                .environmentObject(sceneManager)
                .environmentObject(modelsViewModel)
                .environmentObject(modelDeletionManager)
        }
    }
}
