//
//  LocationCardOutlineView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 10/12/22.
//

import SwiftUI
import macAppBoilerplate

class LocationCardOutlineView: LocationTodoOutlineViewController {

    var location: Location!
    var cardView: LocationCardView!

    override func loadView() {
        super.loadView()
        outlineView.delegate = self
        outlineView.dataSource = self
        outlineView.menu = NSMenu()
        outlineView.menu?.delegate = self
        outlineView.allowsMultipleSelection = true
        outlineView.doubleAction = #selector(onItemDoubleClicked)
    }

    override func getPopUpManager() -> PopUpManager? {
        cardView.cardsView.popUpManager
    }

    override func getTabContent() -> LocationManager? {
        cardView.cardsView.tabContent
    }

    override func getClickedLocation() -> Location? {
        location
    }

    override func getSelectedLocations() -> [Location] {
        return []
    }

    override func getParentOfTodo(todo: Todo) -> Location? {
        return location
    }
}

extension LocationCardOutlineView: NSOutlineViewDataSource, NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
//        return location.todos.filter({ !$0.isDone }).count
        return location.todos.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
//        return location.todos.filter({ !$0.isDone })[index]
        return location.todos[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        false
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? Todo else { return nil }

        let cell = TodoTableViewCell(frame: .zero, isEditable: false)
        cell.todo = item
        cell.outlineView = outlineView
        cell.addTodo()
        return cell
    }

    @objc
    func onItemDoubleClicked() {
        let items = getSelectedTodos()

        let doneCount = items.filter({ $0.isDone }).count
        let notDoneCount = items.count - doneCount

        if notDoneCount > doneCount {
            markAllTodosDone()
        } else {
            markAllTodosNotDone()
        }
    }
}

extension LocationCardOutlineView: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        updateMenuAutomatically(menu)
    }
}
