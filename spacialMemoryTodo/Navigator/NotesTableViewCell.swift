//
//  NotesTableViewCell.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate

class LocationTableViewCell: macAppBoilerplate.StandardTableViewCell {
    var location: Location!

    override func configIcon(icon: NSImageView) {
        super.configIcon(icon: icon)
        icon.image = NSImage(systemSymbolName: "house", accessibilityDescription: nil)
    }

    func addLocation() {
        label.stringValue = location.name
        resizeSubviews(withOldSize: .zero)
    }
}

class TodoTableViewCell: macAppBoilerplate.StandardTableViewCell {
    var todo: Todo!

    override func configIcon(icon: NSImageView) {
        super.configIcon(icon: icon)
        icon.image = NSImage(systemSymbolName: "square", accessibilityDescription: nil)
    }

    func addTodo() {
        label.stringValue = todo.name
        resizeSubviews(withOldSize: .zero)
    }
}
