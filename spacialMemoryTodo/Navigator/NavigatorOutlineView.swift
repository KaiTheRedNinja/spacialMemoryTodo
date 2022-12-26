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
            cell.addTodo()
            return cell
        }

        return nil
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        // get the tab content and selection
        guard let tabContent = tabManager.selectedTabItem() as? LocationManager else { return }
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

            let doneCount = item.todos.lazy.filter({ $0.isDone }).count
            let notDoneCount = item.todos.count - doneCount

            menu.items = [
                .init(title: "Edit Location", action: #selector(editLocation), keyEquivalent: "")
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

            menu.items.append(.init(title: "Delete Location", action: #selector(deleteLocation), keyEquivalent: ""))
        } else if let item = item as? Todo {
            menu.items = [
                .init(title: "Mark As \(item.isDone ? "Not " : "")Done",
                      action: #selector(markTodoAsDone),
                      keyEquivalent: ""),
                .init(title: "Edit Todo",
                      action: #selector(editTodo),
                      keyEquivalent: ""),
                .init(title: "Delete Todo",
                      action: #selector(deleteTodo),
                      keyEquivalent: "")
            ]
        } else {
            menu.items = []
        }
    }

    @objc
    func editLocation() {
        guard let location = clickedLocation() else { return }
        popUpManager?.locationToEdit = location
        popUpManager?.showLocationEditPopup = true
    }

    @objc
    func markAllTodosDone() {
        guard let location = clickedLocation() else { return }
        location.todos.forEach({ $0.isDone = true })
        location.objectWillChange.send()
        LocationManager.save(sender: self.view)
    }

    @objc
    func markAllTodosNotDone() {
        guard let location = clickedLocation() else { return }
        location.todos.forEach({ $0.isDone = false })
        location.objectWillChange.send()
        LocationManager.save(sender: self.view)
    }

    @objc
    func deleteLocation() {
        guard let location = clickedLocation() else { return }

        tabContent?.locations.removeAll { loc in
            loc.id == location.id
        }
        tabContent?.objectWillChange.send()
        LocationManager.save(sender: self.view)
    }

    @objc
    func markTodoAsDone() {
        guard let item = clickedTodo(),
              let location = parentOfClickedTodo()
        else { return }

        location.toggleTodoDone(withID: item.id)
        LocationManager.save(sender: self.view)
    }

    @objc
    func editTodo() {
        guard let item = clickedTodo(),
              let manager = popUpManager
        else { return }

        manager.todoToEdit = item
        manager.showTodoEditPopup = true
    }

    @objc
    func deleteTodo() {
        guard let item = clickedTodo(),
              let location = parentOfClickedTodo()
        else { return }

        location.removeTodo(withID: item.id)
        LocationManager.save(sender: self.view)
    }

    func clickedTodo() -> Todo? {
        let row = outlineView.clickedRow
        guard row >= 0 else { return nil }
        return outlineView.item(atRow: row) as? Todo
    }

    func parentOfClickedTodo() -> Location? {
        guard let todo = clickedTodo() else { return nil }
        return outlineView.parent(forItem: todo) as? Location
    }

    func clickedLocation() -> Location? {
        let row = outlineView.clickedRow
        guard row >= 0 else { return nil }
        return outlineView.item(atRow: row) as? Location
    }
}
