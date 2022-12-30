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

    override func getClickedTodo() -> Todo? {
        let row = outlineView.clickedRow
        guard row >= 0 else { return nil }
        return outlineView.item(atRow: row) as? Todo
    }

    override func getParentOfClickedTodo() -> Location? {
        guard let todo = getClickedTodo() else { return nil }
        return outlineView.parent(forItem: todo) as? Location
    }

    override func getClickedLocation() -> Location? {
        let row = outlineView.clickedRow
        guard row >= 0 else { return nil }
        return outlineView.item(atRow: row) as? Location
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
        let row = outlineView.clickedRow
        guard row >= 0, let item = outlineView.item(atRow: row) else {
            menu.items = []
            return
        }

        if let item = item as? Location {

            let doneCount = item.todos.lazy.filter({ $0.isDone }).count
            let notDoneCount = item.todos.count - doneCount

            menu.items = [
                .init(title: "Edit Location", action: #selector(editLocation), keyEquivalent: ""),
                .init(title: "Focus Location", action: #selector(focusLocation), keyEquivalent: "")
            ]

            if notDoneCount > 0 {
                menu.items.append(.init(title: "Mark \(notDoneCount) Todos As Done",
                                        action: #selector(markAllTodosDone),
                                        keyEquivalent: ""))
            }

            if doneCount > 0 {
                menu.items.append(.init(title: "Mark \(doneCount) Todos As Not Done",
                                        action: #selector(markAllTodosNotDone),
                                        keyEquivalent: ""))
            }

            menu.items.append(.init(title: "Add Todo", action: #selector(addTodo), keyEquivalent: ""))
            menu.items.append(.init(title: "Delete Location", action: #selector(deleteLocation), keyEquivalent: ""))
        } else if let item = item as? Todo {
            menu.items = [
                .init(title: "Mark As \(item.isDone ? "Not " : "")Done",
                      action: #selector(toggleTodoDone),
                      keyEquivalent: ""),
                .init(title: "Edit Todo",
                      action: #selector(editTodo),
                      keyEquivalent: ""),
                .init(title: "Focus Todo",
                      action: #selector(focusTodo),
                      keyEquivalent: ""),
                .init(title: "Delete Todo",
                      action: #selector(deleteTodo),
                      keyEquivalent: "")
            ]
        } else {
            menu.items = []
        }
    }

    @objc func focusLocation() {
        guard let location = getClickedLocation(),
              let tabContent = tabManager.selectedTabItem() as? LocationManager
        else { return }

        tabContent.selectedLocation = location
        tabContent.selectedTodo = nil
    }

    @objc func focusTodo() {
        guard let todo = getClickedTodo(),
              let location = getParentOfClickedTodo(),
              let tabContent = tabManager.selectedTabItem() as? LocationManager
        else { return }

        tabContent.selectedLocation = location
        tabContent.selectedTodo = todo
    }
}
