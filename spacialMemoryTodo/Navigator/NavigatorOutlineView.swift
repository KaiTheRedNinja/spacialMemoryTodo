//
//  NotesOutlineView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate
import Combine

class NavigatorOutlineView: macAppBoilerplate.OutlineViewController {
    var tabContent: MainTabContent?
    var tabContentCancellable: AnyCancellable?
    var locations: [Location] {
        // if tab content exists, return the locations
        if let tabContent {
            return tabContent.locations
        }

        // if it doesn't exist, see if it is stored in tab manager. Else, return empty.
        guard let tabContent = tabManager.selectedTabItem() as? MainTabContent else {
            return []
        }

        // if it is stored in tab manager but tab content does not exist yet, it means
        // that this is the initial load. All top-level items should therefore be expanded.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for location in tabContent.locations {
                self.outlineView.expandItem(location)
            }
        }

        // save the tab content
        self.tabContent = tabContent

        self.tabContentCancellable = tabContent.objectWillChange.sink {
            self.outlineView.reloadData()
        }

        return tabContent.locations
    }

    var tabManagerCancellable: AnyCancellable!

    override func viewDidLoad() {
        super.viewDidLoad()
        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.menu = NSMenu()
        outlineView.menu?.delegate = self
        tabManagerCancellable = tabManager.objectWillChange.sink {
            self.outlineView.reloadData()
        }
    }

    deinit {
        tabManagerCancellable.cancel()
        tabContentCancellable?.cancel()
    }
}

extension NavigatorOutlineView: NSOutlineViewDataSource, NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let item else { return locations.count }

        if let item = item as? Location {
            return item.todos.filter({ !$0.isDone }).count
        }

        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item else { return locations[index] }

        if let item = item as? Location {
            return item.todos.filter({ !$0.isDone })[index]
        }

        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is Location {
            return true
        }

        return false
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let item = item as? Location {
            let cell = LocationTableViewCell(frame: .zero, isEditable: false)
            cell.location = item
            cell.addLocation()
            return cell
        }

        if let item = item as? Todo {
            let cell = TodoTableViewCell(frame: .zero, isEditable: false)
            cell.todo = item
            cell.addTodo()
            return cell
        }

        return nil
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        // get the tab content and selection
        guard let tabContent = tabManager.selectedTabItem() as? MainTabContent else { return }
        guard let selection = outlineView.item(atRow: outlineView.selectedRow) else {
            tabContent.selectedLocation = nil
            tabContent.selectedTodo = nil
            return
        }

        if let selection = selection as? Location {
            tabContent.selectedLocation = selection
            tabContent.selectedTodo = nil
        } else if let selection = selection as? Todo,
                  let location = outlineView.parent(forItem: selection) as? Location {
            tabContent.selectedLocation = location
            tabContent.selectedTodo = selection
        }
    }
}

extension NavigatorOutlineView: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        let row = outlineView.clickedRow
        guard row >= 0, let item = outlineView.item(atRow: row) else {
            menu.items = []
            return
        }

        if let item = item as? Location {
            menu.items = [
                .init(title: "Mark \(item.todos.count) Todos As Done", action: nil, keyEquivalent: ""),
                .init(title: "Delete Location", action: nil, keyEquivalent: "")
            ]
        } else if let item = item as? Todo {
            menu.items = [
                .init(title: "Mark As \(item.isDone ? "Not " : "")Done", action: nil, keyEquivalent: ""),
                .init(title: "Delete Todo", action: nil, keyEquivalent: "")
            ]
        } else {
            menu.items = []
        }
    }
}
