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
        fatalError("Please override this class")
    }
    func getTabContent() -> LocationManager? {
        fatalError("Please override this class")
    }

    func getClickedLocation() -> Location? {
        fatalError("Please override this class")
    }
    func getClickedTodo() -> Todo? {
        fatalError("Please override this class")
    }
    func getParentOfClickedTodo() -> Location? {
        fatalError("Please override this class")
    }
}

extension LocationTodoOutlineViewController {
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
            .init(title: "Delete Todo",
                  action: #selector(deleteTodo),
                  keyEquivalent: "")
        ]
    }

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
        guard let location = getClickedLocation(),
              let tabContent = getTabContent()
        else { return }

        tabContent.locations.removeAll { loc in
            loc.id == location.id
        }
        tabContent.objectWillChange.send()
        LocationManager.save(sender: self.view)
    }

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

    @objc func focusLocation() {
        guard let location = getClickedLocation(),
              let tabContent = getTabContent()
        else { return }

        tabContent.selectedLocation = location
        tabContent.selectedTodo = nil
    }

    @objc func focusTodo() {
        guard let todo = getClickedTodo(),
              let location = getParentOfClickedTodo(),
              let tabContent = getTabContent()
        else { return }

        tabContent.selectedLocation = location
        tabContent.selectedTodo = todo
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
