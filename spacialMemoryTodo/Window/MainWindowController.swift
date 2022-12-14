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
        let navigator = NavigatorSidebar(popUpManager: popUpManager)
        navigator.isNavigatorSidebar = true
        return navigator
    }

    override func getInspectorProtocol() -> SidebarProtocol {
        return NavigatorSidebar(popUpManager: popUpManager)
    }

    override func getTabBarProtocol() -> TabBarProtocol {
        return TabBar()
    }

    override func getWorkspaceProtocol() -> WorkspaceProtocol {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tabManager.openTab(tab: LocationManager.default)
        }
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
        items.append(.saveItem)
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
        case .saveItem:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.saveItem)
            toolbarItem.label = "Save"
            toolbarItem.paletteLabel = "Save"
            toolbarItem.toolTip = "Save Locations"
            toolbarItem.isBordered = true
            toolbarItem.target = self
            toolbarItem.action = #selector(saveLocations)
            toolbarItem.image = NSImage(
                systemSymbolName: "circle",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))

            return toolbarItem
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }

    @objc
    func addNewItem() {
        let locManager = LocationManager.default
        let location = locManager.locationForNewTodo?(CGRect.defaultLocationCardSize.size) ?? .zero
        locManager.locations.append(.init(name: "Untitled Location",
                                          todos: [],
                                          colour: popUpManager.lastColour,
                                          rect: .init(x: location.x,
                                                      y: location.y,
                                                      width: CGRect.defaultLocationCardSize.width,
                                                      height: CGRect.defaultLocationCardSize.height)))
        locManager.objectWillChange.send()

        LocationManager.save(sender: tabManager)
    }

    @objc
    func saveLocations() {
        LocationManager.save(sender: tabManager)
    }
}

extension NSToolbarItem.Identifier {
    static let addNewItem = NSToolbarItem.Identifier("addNewItem")
    static let saveItem = NSToolbarItem.Identifier("saveItem")
}
