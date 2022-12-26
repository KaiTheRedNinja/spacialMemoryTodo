//
//  LocationManager.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 26/12/22.
//

import SwiftUI
import macAppBoilerplate

class LocationManager: macAppBoilerplate.TabBarItemRepresentable, ObservableObject {

    // tab item representable things
    var tabID: macAppBoilerplate.TabBarID = TabID.mainContent
    var title: String = "MainContent"
    var icon: NSImage = NSImage(systemSymbolName: "circle", accessibilityDescription: nil)!
    var iconColor: Color = .accentColor

    // the locations
    @Published var locations: [Location] = [
        .init(name: "test 1 with the really long name", todos: [
            .init(name: "test todo"),
            .init(name: "test threedo"),
            .init(name: "test fourdo"),
            .init(name: "test fivedo")
        ], rect: .init(x: 0, y: 0, width: 300, height: 100)),
        .init(name: "test 2", todos: [
        ], rect: .init(x: 300, y: 300, width: 300, height: 100))
    ]

    // the selection
    @Published var selectedLocation: Location?
    @Published var selectedTodo: Todo?

    // used for creating new locations
    var locationForNewTodo: ((CGSize) -> CGPoint)?
}
