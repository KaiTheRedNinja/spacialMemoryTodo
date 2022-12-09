//
//  NotesOutlineView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate

class NotesOutlineView: macAppBoilerplate.OutlineViewController {
    var locations: [Location] = [
        .init(name: "test location", todos: [
            .init(name: "test todo"),
            .init(name: "test threedo")
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        outlineView.dataSource = self
        outlineView.delegate = self
    }
}

extension NotesOutlineView: NSOutlineViewDataSource, NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let item else { return locations.count }

        if let item = item as? Location {
            return item.todos.filter({ !$0.isDone }).count
        }

        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item else { return locations[index] }

        if let item = item as? Location {
            return item.todos.filter({ !$0.isDone })[index]
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
}
