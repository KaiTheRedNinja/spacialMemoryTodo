//
//  Todo.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import Foundation

class Todo: Identifiable, Equatable, ObservableObject, Codable {
    var name: String
    var isDone: Bool

    init(name: String, isDone: Bool = false) {
        self.name = name
        self.isDone = isDone
    }

    var id = UUID()

    static func == (lhs: Todo, rhs: Todo) -> Bool {
        lhs.id == rhs.id
    }
}
