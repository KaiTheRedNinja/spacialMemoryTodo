//
//  NotesTableViewCell.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import Combine
import macAppBoilerplate

class LocationTableViewCell: macAppBoilerplate.StandardTableViewCell {
    var location: Location!
    var locationCancellable: AnyCancellable?

    override func configIcon(icon: NSImageView) {
        super.configIcon(icon: icon)
        icon.image = NSImage(systemSymbolName: "location.circle", accessibilityDescription: nil)
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
            locationCancellable = location.objectWillChange.sink {
                self.addLocation()
            }
        }
    }

    deinit {
        locationCancellable?.cancel()
    }
}

class TodoTableViewCell: macAppBoilerplate.StandardTableViewCell {
    var todo: Todo!
    var todoCancellable: AnyCancellable?

    override func configIcon(icon: NSImageView) {
        super.configIcon(icon: icon)
        icon.image = NSImage(systemSymbolName: "square", accessibilityDescription: nil)
    }

    func addTodo() {
        label.stringValue = todo.name
        icon.image = NSImage(systemSymbolName: todo.isDone ? "checkmark.square.fill" : "square", accessibilityDescription: nil)
        resizeSubviews(withOldSize: .zero)

        if todoCancellable == nil {
            todoCancellable = todo.objectWillChange.sink {
                self.addTodo()
            }
        }
    }

    deinit {
        todoCancellable?.cancel()
    }
}
