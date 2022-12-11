//
//  LocationCardOutlineView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 10/12/22.
//

import SwiftUI
import macAppBoilerplate

class LocationCardOutlineView: macAppBoilerplate.OutlineViewController {

    var location: Location!

    override func loadView() {
        super.loadView()
        outlineView.delegate = self
        outlineView.dataSource = self
    }
}

extension LocationCardOutlineView: NSOutlineViewDataSource, NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return location.todos.filter({ !$0.isDone }).count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return location.todos.filter({ !$0.isDone })[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        false
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? Todo else { return nil }

        let cell = TodoTableViewCell(frame: .zero, isEditable: false)
        cell.todo = item
        cell.addTodo()
        return cell
    }
}
