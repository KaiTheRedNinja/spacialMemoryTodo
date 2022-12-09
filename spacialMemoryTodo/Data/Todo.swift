//
//  Todo.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import Foundation

class Todo {
    var name: String
    var isDone: Bool

    init(name: String, isDone: Bool = false) {
        self.name = name
        self.isDone = isDone
    }
}
