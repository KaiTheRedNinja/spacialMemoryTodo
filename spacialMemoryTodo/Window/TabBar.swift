//
//  TabBar.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate

class TabBar: macAppBoilerplate.TabBarProtocol {
    func getDisableTabs() -> Bool? {
        return true
    }

    func configWindow(_ window: NSWindow) {
        window.title = "Spacial Memory Todo"
        window.toolbarStyle = .unified
    }
}

class MainTabContent: macAppBoilerplate.TabBarItemRepresentable, ObservableObject {

    // tab item representable things
    var tabID: macAppBoilerplate.TabBarID = TabID.mainContent
    var title: String = "MainContent"
    var icon: NSImage = NSImage(systemSymbolName: "circle", accessibilityDescription: nil)!
    var iconColor: Color = .accentColor

    // the locations
    var locations: [Location] = [
        .init(name: "test 1 with the really long name", todos: [
            .init(name: "test todo"),
            .init(name: "test threedo")
        ], rect: .init(x: 0, y: 0, width: 300, height: 100)),
        .init(name: "test 2", todos: [
        ], rect: .init(x: 300, y: 300, width: 300, height: 100))
    ]
}

enum TabID: macAppBoilerplate.TabBarID {
    // since there will only ever be one mainContent, there is no need for distinguishing things
    var id: String { "mainContent" }
    case mainContent
}
