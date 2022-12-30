//
//  NotesOutlineView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate
import Combine

class NavigatorOutlineView: LocationTodoOutlineViewController {
    var popUpManager: PopUpManager?
    var tabContent: LocationManager?
    var tabContentCancellable: AnyCancellable?
    var locations: [Location] {
        // if tab content exists, return the locations
        if let tabContent {
            return tabContent.locations
        }

        // if it doesn't exist, see if it is stored in tab manager. Else, return empty.
        guard let tabContent = tabManager.selectedTabItem() as? LocationManager else {
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
        outlineView.allowsMultipleSelection = true
        tabManagerCancellable = tabManager.objectWillChange.sink {
            self.outlineView.reloadData()
        }
    }

    deinit {
        tabManagerCancellable.cancel()
        tabContentCancellable?.cancel()
    }

    override func getPopUpManager() -> PopUpManager? {
        popUpManager
    }

    override func getTabContent() -> LocationManager? {
        tabContent
    }
}

extension NavigatorOutlineView: NSOutlineViewDataSource, NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let item else { return locations.count }

        if let item = item as? Location {
//            return item.todos.filter({ !$0.isDone }).count
            return item.todos.count
        }

        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item else { return locations[index] }

        if let item = item as? Location {
//            return item.todos.filter({ !$0.isDone })[index]
            return item.todos[index]
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
            cell.outlineView = outlineView
            cell.addLocation()
            return cell
        }

        if let item = item as? Todo {
            let cell = TodoTableViewCell(frame: .zero, isEditable: false)
            cell.todo = item
            cell.outlineView = outlineView
            cell.addTodo()
            return cell
        }

        return nil
    }
}

extension NavigatorOutlineView: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        updateMenuAutomatically(menu)
    }
}
