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

    override func getClickedTodo() -> Todo? {
        let row = outlineView.clickedRow
        guard row >= 0 else { return nil }
        return outlineView.item(atRow: row) as? Todo
    }

    override func getParentOfClickedTodo() -> Location? {
        location
    }

    func selectedTodos() -> [Todo] {
        let rows = outlineView.selectedRowIndexes

        return rows.compactMap { row in
            outlineView.item(atRow: row) as? Todo
        }
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
        let items = selectedTodos()

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
        menu.items = []

        // check for single-row or no-row selection clicks
        let rows = outlineView.selectedRowIndexes
        if rows.count <= 1 {
            let row = outlineView.clickedRow
            guard let item = outlineView.item(atRow: row) as? Todo else { return }
            updateMenuForTodo(menu, todo: item)
            return
        }

        var items: [Todo] = []
        for row in rows {
            guard row >= 0,
                  let item = outlineView.item(atRow: row) as? Todo else {
                continue
            }
            items.append(item)
        }

        let doneCount = items.filter({ $0.isDone }).count
        let notDoneCount = items.count - doneCount

        if notDoneCount > 0 {
            menu.items.append(.init(title: "Mark \(notDoneCount) Todos As Done",
                                    action: #selector(markSelectedTodosDone),
                                    keyEquivalent: ""))
        }

        if doneCount > 0 {
            menu.items.append(.init(title: "Mark \(doneCount) Todos As Not Done",
                                    action: #selector(markSelectedTodosNotDone),
                                    keyEquivalent: ""))
        }

        menu.items.append(.init(title: "Delete \(items.count) Todos",
                                action: #selector(deleteTodos),
                                keyEquivalent: ""))
    }

    @objc
    func markSelectedTodosDone() {
        let items = selectedTodos()

        for item in items {
            item.isDone = true
        }
        location.objectWillChange.send()
        LocationManager.save(sender: self.view)
    }

    @objc
    func markSelectedTodosNotDone() {
        let items = selectedTodos()

        for item in items {
            item.isDone = false
        }
        location.objectWillChange.send()
        LocationManager.save(sender: self.view)
    }

    @objc
    func deleteTodos() {
        let items = selectedTodos()

        for item in items {
            location.removeTodo(withID: item.id)
        }
        LocationManager.save(sender: self.view)
    }
}
