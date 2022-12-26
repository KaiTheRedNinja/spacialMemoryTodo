//
//  MainWindowController.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import Combine
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

        // custom items
        items.append(.addNewItem)

        return items
    }

    override func toolbar(_ toolbar: NSToolbar,
                          itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                          willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        // add the default items
        if let defaultItem = builtinDefaultToolbar(toolbar,
                                                   itemForItemIdentifier: itemIdentifier,
                                                   willBeInsertedIntoToolbar: flag) {
            return defaultItem
        }

        switch itemIdentifier {
        case .addNewItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.addNewItem)
            toolbarItem.label = "Add New Location"
            toolbarItem.paletteLabel = "Add New Location"
            toolbarItem.toolTip = "Add a New Location"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(addNewItem)
            toolbarItem.image = NSImage(
                systemSymbolName: "plus",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))

            return toolbarItem
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }

    @objc
    func addNewItem() {
        guard let tabContent = tabManager.selectedTabItem() as? MainTabContent else { return }
        tabContent.locations.append(.init(name: "Untitled Location", todos: []))
        tabContent.objectWillChange.send()
    }
}

extension NSToolbarItem.Identifier {
     static let addNewItem = NSToolbarItem.Identifier("addNewItem")
}
