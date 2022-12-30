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

    func selectedTodos() -> [Todo] {
        let rows = outlineView.selectedRowIndexes

        return rows.compactMap { row in
            outlineView.item(atRow: row) as? Todo
        }
    }

    func selectedLocations() -> [Location] {
        let rows = outlineView.selectedRowIndexes

        return rows.compactMap { row in
            outlineView.item(atRow: row) as? Location
        }
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
        menu.items = []

        // if there are no selections,
        // a single selection that was the click, or
        // the click was outside the selection, then update the menu for a single item
        let rows = outlineView.selectedRowIndexes
        let row = outlineView.clickedRow
        if  (rows.isEmpty) ||
            (rows.count == 1 && rows.contains(row)) ||
            (!rows.contains(row)) {
            if let item = outlineView.item(atRow: row) as? Location {
                updateMenuForLocation(menu, location: item)
            } else if let item = outlineView.item(atRow: row) as? Todo {
                updateMenuForTodo(menu, todo: item)
            }
            return
        }

        // get the selected locations and todos
        var selectedLocations = selectedLocations()
        var selectedTodos = selectedTodos()

        // get the clicked item
        guard let item = outlineView.item(atRow: row),
              item is Location || item is Todo else {
            menu.items = []
            return
        }

        // add it to its respective category if it isn't already there
        if let item = item as? Location, !selectedLocations.contains(item) {
            selectedLocations.append(item)
        } else if let item = item as? Todo, !selectedTodos.contains(item) {
            selectedTodos.append(item)
        }

        // add location related things
        addLocationMenu(menu, selectedLocations: selectedLocations)

        // add todo related things
        addTodoMenu(menu, selectedTodos: selectedTodos)
    }

    func addLocationMenu(_ menu: NSMenu, selectedLocations: [Location]) {
        // if it is the only location, add only that
        if selectedLocations.count == 1, let item = selectedLocations.first {
            updateMenuForLocation(menu, location: item)
        } else if selectedLocations.count > 1 {
            // if it is not the only location, add the menu for many locations
            menu.items.append(.init(title: "Delete \(selectedLocations.count) Locations",
                                    action: #selector(deleteSelectedLocations),
                                    keyEquivalent: ""))
        } // if there are no locations, do not add any menu for it.
    }

    func addTodoMenu(_ menu: NSMenu, selectedTodos: [Todo]) {
        // if it is the only todo, add only that
        if selectedTodos.count == 1, let item = selectedTodos.first {
            let items = menu.items
            updateMenuForTodo(menu, todo: item)
            let newItems = menu.items
            menu.items = []
            if !items.isEmpty {
                menu.items = items
                menu.addSeparator()
            }
            menu.items.append(contentsOf: newItems)
        } else if selectedTodos.count > 1 {
            if !menu.items.isEmpty {
                menu.addSeparator()
            }
            let doneCount = selectedTodos.filter({ $0.isDone }).count
            let notDoneCount = selectedTodos.count - doneCount

            if notDoneCount > 0 {
                menu.items.append(.init(title: "Mark \(notDoneCount) Selected Todos As Done",
                                        action: #selector(markSelectedTodosDone),
                                        keyEquivalent: ""))
            }

            if doneCount > 0 {
                menu.items.append(.init(title: "Mark \(doneCount) Selected Todos As Not Done",
                                        action: #selector(markSelectedTodosNotDone),
                                        keyEquivalent: ""))
            }

            menu.items.append(.init(title: "Delete \(selectedTodos.count) Todos",
                                    action: #selector(deleteTodos),
                                    keyEquivalent: ""))
        } // if there are no todos, do not add any menu for it.
    }

    @objc
    func deleteSelectedLocations() {
        let selectedLocations = selectedLocations()
        guard let tabContent, !selectedLocations.isEmpty else { return }

        for selectedLocation in selectedLocations {
            tabContent.locations.removeAll(where: { loc in
                loc == selectedLocation
            })
        }
        tabContent.objectWillChange.send()
        LocationManager.save(sender: self.view)
    }

    @objc
    func markSelectedTodosDone() {
        let items = selectedTodos()
        var locationsToUpdate: [Location] = []

        for item in items {
            item.isDone = true
            if let itemParent = outlineView.parent(forItem: item) as? Location {
                locationsToUpdate.append(itemParent)
            }
        }
        locationsToUpdate.forEach({ $0.objectWillChange.send() })
        LocationManager.save(sender: self.view)
    }

    @objc
    func markSelectedTodosNotDone() {
        let items = selectedTodos()
        var locationsToUpdate: [Location] = []

        for item in items {
            item.isDone = false
            if let itemParent = outlineView.parent(forItem: item) as? Location {
                locationsToUpdate.append(itemParent)
            }
        }
        locationsToUpdate.forEach({ $0.objectWillChange.send() })
        LocationManager.save(sender: self.view)
    }

    @objc
    func deleteTodos() {
        let items = selectedTodos()
        var locationsToUpdate: [Location] = []

        for item in items {
            guard let itemParent = outlineView.parent(forItem: item) as? Location else { continue }
            locationsToUpdate.append(itemParent)
            itemParent.removeTodo(withID: item.id)
        }
        locationsToUpdate.forEach({ $0.objectWillChange.send() })
        LocationManager.save(sender: self.view)
    }
}
