//
//  LocationTodoOutlineHelper.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 29/12/22.
//

import SwiftUI
import macAppBoilerplate

class LocationTodoOutlineViewController: macAppBoilerplate.OutlineViewController {
    func getPopUpManager() -> PopUpManager? {
        fatalError("Please override this function")
    }

    func getClickedLocation() -> Location? {
        let row = outlineView.clickedRow
        guard row >= 0 else { return nil }
        return outlineView.item(atRow: row) as? Location
    }
    func getClickedTodo() -> Todo? {
        let row = outlineView.clickedRow
        guard row >= 0 else { return nil }
        return outlineView.item(atRow: row) as? Todo
    }
    func getParentOfClickedTodo() -> Location? {
        if let clickedTodo = getClickedTodo(),
           let parent = getParentOfTodo(todo: clickedTodo) {
            return parent
        }
        return nil
    }

    func getSelectedTodos() -> [Todo] {
        let rows = outlineView.selectedRowIndexes

        return rows.compactMap { row in
            outlineView.item(atRow: row) as? Todo
        }
    }
    func getSelectedLocations() -> [Location] {
        let rows = outlineView.selectedRowIndexes

        return rows.compactMap { row in
            outlineView.item(atRow: row) as? Location
        }
    }
    func getParentOfTodo(todo: Todo) -> Location? {
        return outlineView.parent(forItem: todo) as? Location
    }
}

extension LocationTodoOutlineViewController {
    // MARK: Menu updates
    func updateMenuAutomatically(_ menu: NSMenu) {
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
        var selectedLocations = getSelectedLocations()
        var selectedTodos = getSelectedTodos()

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
        addLocationsMenu(menu, selectedLocations: selectedLocations)

        // add todo related things
        addTodosMenu(menu, selectedTodos: selectedTodos)
    }

    func updateMenuForLocation(_ menu: NSMenu, location: Location) {
        let doneCount = location.todos.lazy.filter({ $0.isDone }).count
        let notDoneCount = location.todos.count - doneCount

        menu.items = [
            .init(title: "Edit Location", action: #selector(editLocation), keyEquivalent: ""),
            .init(title: "Focus Location", action: #selector(focusLocation), keyEquivalent: "")
        ]

        menu.addSeparator()

        menu.items.append(.init(title: "Add Todo", action: #selector(addTodo), keyEquivalent: ""))

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

        menu.addSeparator()

        menu.items.append(.init(title: "Delete Location", action: #selector(deleteLocation), keyEquivalent: ""))
    }

    func updateMenuForTodo(_ menu: NSMenu, todo: Todo) {
        menu.items = [
            .init(title: "Mark As \(todo.isDone ? "Not " : "")Done",
                  action: #selector(toggleTodoDone),
                  keyEquivalent: ""),
            .separator(),
            .init(title: "Edit Todo",
                  action: #selector(editTodo),
                  keyEquivalent: ""),
            .init(title: "Focus Todo",
                  action: #selector(focusTodo),
                  keyEquivalent: ""),
            .separator(),
            .init(title: "Delete Todo",
                  action: #selector(deleteTodo),
                  keyEquivalent: "")
        ]
    }

    func addLocationsMenu(_ menu: NSMenu, selectedLocations: [Location]) {
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

    func addTodosMenu(_ menu: NSMenu, selectedTodos: [Todo]) {
        // if there are no todos, do not add any menu for it
        guard !selectedTodos.isEmpty else { return }

        // adding the single todo menu looks odd, so just add the multi todo menu
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
    }

    // MARK: Single location functions
    @objc func editLocation() {
        guard let location = getClickedLocation(),
              let popUpManager = getPopUpManager()
        else { return }
        popUpManager.locationToEdit = location
        popUpManager.showLocationEditPopup = true
    }

    @objc func markAllTodosDone() {
        guard let location = getClickedLocation() else { return }
        location.todos.forEach({ $0.isDone = true })
        location.objectWillChange.send()
        LocationManager.save(sender: self.view)
    }

    @objc func markAllTodosNotDone() {
        guard let location = getClickedLocation() else { return }
        location.todos.forEach({ $0.isDone = false })
        location.objectWillChange.send()
        LocationManager.save(sender: self.view)
    }

    @objc func addTodo() {
        guard let location = getClickedLocation() else { return }
        location.todos.append(.init(name: "Untitled Todo"))
        location.objectWillChange.send()

        LocationManager.save(sender: self.view)
    }

    @objc func deleteLocation() {
        guard let location = getClickedLocation() else { return }
        let locManager = LocationManager.default

        locManager.locations.removeAll { loc in
            loc.id == location.id
        }
        locManager.objectWillChange.send()
        LocationManager.save(sender: self.view)
    }

    // MARK: Single todo functions
    @objc func toggleTodoDone () {
        guard let item = getClickedTodo(),
              let location = getParentOfClickedTodo()
        else { return }

        location.toggleTodoDone(withID: item.id)
        LocationManager.save(sender: self.view)
    }

    @objc func editTodo() {
        guard let item = getClickedTodo(),
              let manager = getPopUpManager()
        else { return }

        manager.todoToEdit = item
        manager.showTodoEditPopup = true
    }

    @objc func deleteTodo() {
        guard let item = getClickedTodo(),
              let location = getParentOfClickedTodo()
        else { return }

        location.removeTodo(withID: item.id)
        LocationManager.save(sender: self.view)
    }

    // MARK: Focusing
    @objc func focusLocation() {
        guard let location = getClickedLocation() else { return }
        let locManager = LocationManager.default

        locManager.selectedLocation = location
        locManager.selectedTodo = nil
    }

    @objc func focusTodo() {
        guard let todo = getClickedTodo(),
              let location = getParentOfClickedTodo()
        else { return }
        let locManager = LocationManager.default

        locManager.selectedLocation = location
        locManager.selectedTodo = todo
    }

    // MARK: Multiple location functions
    @objc func deleteSelectedLocations() {
        let selectedLocations = getSelectedLocations()
        guard !selectedLocations.isEmpty else { return }
        let locManager = LocationManager.default

        for selectedLocation in selectedLocations {
            locManager.locations.removeAll(where: { loc in
                loc == selectedLocation
            })
        }
        locManager.objectWillChange.send()
        LocationManager.save(sender: self.view)
    }

    // MARK: Multiple todo functions
    @objc func markSelectedTodosDone() {
        let items = getSelectedTodos()
        var locationsToUpdate: [Location] = []

        for item in items {
            item.isDone = true
            if let itemParent = getParentOfTodo(todo: item) {
                locationsToUpdate.append(itemParent)
            }
        }
        locationsToUpdate.forEach({ $0.objectWillChange.send() })
        LocationManager.save(sender: self.view)
    }

    @objc func markSelectedTodosNotDone() {
        let items = getSelectedTodos()
        var locationsToUpdate: [Location] = []

        for item in items {
            item.isDone = false
            if let itemParent = getParentOfTodo(todo: item) {
                locationsToUpdate.append(itemParent)
            }
        }
        locationsToUpdate.forEach({ $0.objectWillChange.send() })
        LocationManager.save(sender: self.view)
    }

    @objc func deleteTodos() {
        let items = getSelectedTodos()
        var locationsToUpdate: [Location] = []

        for item in items {
            guard let itemParent = getParentOfTodo(todo: item) else { continue }
            locationsToUpdate.append(itemParent)
            itemParent.removeTodo(withID: item.id)
        }
        locationsToUpdate.forEach({ $0.objectWillChange.send() })
        LocationManager.save(sender: self.view)
    }

    @objc func onItemDoubleClicked() {
        let items = getSelectedTodos()

        let doneCount = items.filter({ $0.isDone }).count
        let notDoneCount = items.count - doneCount

        if notDoneCount > doneCount {
            markSelectedTodosDone()
        } else {
            markSelectedTodosNotDone()
        }
    }
}

extension NSMenu {
    func addSeparator(at index: Int = -1) {
        if (0..<items.count).contains(index) {
            items.insert(.separator(), at: index)
        } else {
            items.append(.separator())
        }
    }
}
