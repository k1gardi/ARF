//
//  SessionSettings.swift
//  ARF
//
//  Created by Kaewan Gardi on 10/19/22.
//

import SwiftUI

class SessionSettings: ObservableObject {
    @Published var isPeopleOcclusionEnabled: Bool = false
    @Published var isObjectOcclusionEnabled: Bool = false
    @Published var isLidarEnabled: Bool = false
    @Published var isMultiuserEnabled: Bool = false
    
    

}
