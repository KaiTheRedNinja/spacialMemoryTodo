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
    var locManagerCancellable: AnyCancellable?

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

        let manager = LocationManager.default

        // Expand all top level items
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for location in manager.locations {
                self.outlineView.expandItem(location)
            }
        }

        // Set up the listener
        self.locManagerCancellable = manager.objectWillChange.sink { .now() + 0.005 } receiveValue: {
            // the value of LocationManager.default.hideCompletedTodos seems to take
            // a while to update, so we wait a bit and then run the code
            self.outlineView.reloadData()
        }
    }

    deinit {
        tabManagerCancellable.cancel()
        locManagerCancellable?.cancel()
    }

    override func getPopUpManager() -> PopUpManager? {
        popUpManager
    }
}

extension NavigatorOutlineView: NSOutlineViewDataSource, NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let item else { return LocationManager.default.locations.count }

        if let item = item as? Location {
            let manager = LocationManager.default

            let todos = manager.hideCompletedTodos ?
                            item.todos.filter({ !$0.isDone }) :
                            item.todos

            guard !manager.searchTerm.isEmpty else {
                return todos.count
            }

            // filter the todos
            return todos.filter({ $0.name.contains(manager.searchTerm) }).count
        }

        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item else { return LocationManager.default.locations[index] }

        if let item = item as? Location {
            let manager = LocationManager.default

            let todos = manager.hideCompletedTodos ?
                            item.todos.filter({ !$0.isDone }) :
                            item.todos

            guard !manager.searchTerm.isEmpty else {
                return todos[index]
            }

            // filter the todos
            return todos.filter({ $0.name.contains(manager.searchTerm) })[index]
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
            let cell = LocationTableViewCell(frame: .zero, isEditable: true)
            cell.location = item
            cell.outlineView = outlineView
            cell.addLocation()
            return cell
        }

        if let item = item as? Todo {
            let cell = TodoTableViewCell(frame: .zero, isEditable: true)
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
