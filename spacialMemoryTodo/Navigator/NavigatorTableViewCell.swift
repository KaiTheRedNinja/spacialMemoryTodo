//
//  NavigatorTableViewCell.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import Combine
import macAppBoilerplate

class LocationTableViewCell: macAppBoilerplate.StandardTableViewCell {
    weak var location: Location!
    var locationCancellable: AnyCancellable?

    weak var outlineView: NSOutlineView?

    override func configIcon(icon: NSImageView) {
        super.configIcon(icon: icon)
        icon.image = NSImage(systemSymbolName: "location.circle", accessibilityDescription: nil)
    }

    override func configLabel(label: NSTextField, isEditable: Bool) {
        super.configLabel(label: label, isEditable: isEditable)
        label.delegate = self
    }

    func addLocation() {
        label.stringValue = location.name
        secondaryLabel.stringValue = "\(location.todos.filter({ !$0.isDone }).count)"

        if let colour = PossibleColours.swiftColours[location.colour] {
            icon.contentTintColor = NSColor(colour)
        }

        resizeSubviews(withOldSize: .zero)

        // add the watcher
        if locationCancellable == nil {
            locationCancellable = location.objectWillChange.sink { [weak self] in
                // first, verify that this table view cell is actually the correct one
                guard let self,
                      let index = self.outlineView?.row(forItem: self.location),
                      let view = self.outlineView?.view(atColumn: 0,
                                                        row: index,
                                                        makeIfNecessary: false) as? LocationTableViewCell,
                      self == view
                else {
                    // cancel the watcher and return
                    self?.locationCancellable?.cancel()
                    return
                }

                self.outlineView?.reloadItem(self.location, reloadChildren: true)
            }
        }
    }

    deinit {
        locationCancellable?.cancel()
    }
}

class TodoTableViewCell: macAppBoilerplate.StandardTableViewCell {
    weak var todo: Todo!
    var todoCancellable: AnyCancellable?

    weak var outlineView: NSOutlineView?

    override func configIcon(icon: NSImageView) {
        super.configIcon(icon: icon)
        icon.image = NSImage(systemSymbolName: "square", accessibilityDescription: nil)
    }

    override func configLabel(label: NSTextField, isEditable: Bool) {
        super.configLabel(label: label, isEditable: isEditable)
        label.delegate = self
    }

    func addTodo() {
        label.stringValue = todo.name
        toolTip = todo.name
        icon.image = NSImage(systemSymbolName: todo.isDone ? "checkmark.square.fill" : "square",
                             accessibilityDescription: nil)

        if let dueDate = todo.dueDate {
            secondaryLabel.stringValue = Date.now.prettyTimeUntil(laterDate: dueDate)
        }

        resizeSubviews(withOldSize: .zero)

        if todoCancellable == nil {
            todoCancellable = todo.objectWillChange.sink { [weak self] in
                // first, verify that this table view cell is actually the correct one
                guard let self,
                      let index = self.outlineView?.row(forItem: self.todo),
                      let view = self.outlineView?.view(atColumn: 0,
                                                        row: index,
                                                        makeIfNecessary: false) as? TodoTableViewCell,
                      self == view
                else {
                    // cancel the watcher and return
                    self?.todoCancellable?.cancel()
                    return
                }

                self.addTodo()
            }
        }
    }

    deinit {
        todoCancellable?.cancel()
    }
}
