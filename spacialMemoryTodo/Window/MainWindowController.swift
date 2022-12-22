//
//  MainWindowController.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate

class MainWindowController: macAppBoilerplate.MainWindowController {
    var popUpManager: PopUpManager = .init()

    override func getNavigatorProtocol() -> SidebarProtocol {
        return NavigatorSidebar(popUpManager: popUpManager)
    }

    override func getInspectorProtocol() -> SidebarProtocol {
        return NavigatorSidebar(popUpManager: popUpManager)
    }

    override func getTabBarProtocol() -> TabBarProtocol {
        return TabBar()
    }

    override func getWorkspaceProtocol() -> WorkspaceProtocol {
        return Workspace(popUpManager: popUpManager)
    }

    override func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        var items: [NSToolbarItem.Identifier] = []
        // add the leading items (the navigator sidebar, spacer and sidebar tracker)
        items.append(contentsOf: defaultLeadingItems(toolbar))

        // the middle items
        items.append(.flexibleSpace)
        items.append(.flexibleSpace)
        items.append(.flexibleSpace)
        return items
    }
}
