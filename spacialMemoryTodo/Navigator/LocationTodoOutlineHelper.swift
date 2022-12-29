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

    @objc func markTodoAsDone() {
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
}
