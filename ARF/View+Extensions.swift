//
//  View+Extensions.swift
//  ARF
//
//  Created by Kaewan Gardi on 10/19/22.
//

import SwiftUI

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}
