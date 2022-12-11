//
//  NotesOutlineView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate
import Combine

class NotesOutlineView: macAppBoilerplate.OutlineViewController {
    private var mainTabNotLoadedYet: Bool = true
    var locations: [Location] {
        guard let tabContent = tabManager.selectedTabItem() as? MainTabContent else {
            mainTabNotLoadedYet = true
            return []
        }

        if mainTabNotLoadedYet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                for location in tabContent.locations {
                    self.outlineView.expandItem(location)
                }
            }
        }

        mainTabNotLoadedYet = false

        return tabContent.locations
    }

    var mainTabContentCancellable: AnyCancellable!

    override func viewDidLoad() {
        super.viewDidLoad()
        outlineView.dataSource = self
        outlineView.delegate = self
        mainTabContentCancellable = tabManager.objectWillChange.sink {
            self.outlineView.reloadData()
        }
    }

    deinit {
        mainTabContentCancellable.cancel()
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

    func outlineViewSelectionDidChange(_ notification: Notification) {
        // get the tab content and selection
        guard let tabContent = tabManager.selectedTabItem() as? MainTabContent else { return }
        guard let selection = outlineView.item(atRow: outlineView.selectedRow) else {
            tabContent.selection = nil
            return
        }

        if let selection = selection as? Location {
            tabContent.selection = .one(selection)
        } else if let selection = selection as? Todo {
            tabContent.selection = .two(selection)
        }
    }
}
