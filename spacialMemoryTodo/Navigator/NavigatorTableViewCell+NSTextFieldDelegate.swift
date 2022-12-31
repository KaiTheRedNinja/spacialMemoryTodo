//
//  NavigatorTableViewCell+NSTextFieldDelegate.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 31/12/22.
//

import SwiftUI

extension LocationTableViewCell: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        guard !label.stringValue.isEmpty else {
            label.stringValue = location.name
            return
        }

        location.name = label.stringValue
        location.objectWillChange.send()
        if let outlineView {
            LocationManager.save(sender: outlineView)
        }
    }
}

extension TodoTableViewCell: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        guard !label.stringValue.isEmpty else {
            label.stringValue = todo.name
            return
        }

        todo.name = label.stringValue
        todo.objectWillChange.send()
        if let outlineView {
            LocationManager.save(sender: outlineView)
        }
    }
}
