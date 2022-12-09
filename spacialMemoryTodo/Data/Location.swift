//
//  Location.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import Foundation

class Location {
    var name: String
    var todos: [Todo]

    init(name: String, todos: [Todo]) {
        self.name = name
        self.todos = todos
    }
}
