//
//  Log.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 22/12/22.
//

import Foundation

enum Log {
    /// Wrapper function for `print()`. Casuses a warning whenever used.
    @available(*, deprecated, message: "Please remove this eventually")
    static func info(_ items: Any..., separator: String = "", terminator: String = "\n") {
        print(items, separator: separator, terminator: terminator) // swiftlint:disable:this print_warning
    }
}
