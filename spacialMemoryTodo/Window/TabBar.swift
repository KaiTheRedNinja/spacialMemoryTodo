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

enum TabID: macAppBoilerplate.TabBarID {
    // since there will only ever be one mainContent, there is no need for distinguishing things
    var id: String { "mainContent" }
    case mainContent
}
