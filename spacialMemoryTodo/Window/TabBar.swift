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
        window.toolbarStyle = .unified
    }
}

class MainTabContent: macAppBoilerplate.TabBarItemRepresentable {
    var tabID: macAppBoilerplate.TabBarID = TabID.mainContent

    var title: String = "MainContent"

    var icon: NSImage = NSImage(systemSymbolName: "circle", accessibilityDescription: nil)!

    var iconColor: Color = .accentColor
}

enum TabID: macAppBoilerplate.TabBarID {
    var id: String { "mainContent" }

    case mainContent
}
