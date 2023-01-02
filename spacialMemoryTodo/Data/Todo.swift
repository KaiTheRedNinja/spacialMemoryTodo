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

    let creationDate: Date
    var dueDate: Date?

    init(name: String, creationDate: Date = .now, dueDate: Date? = nil, isDone: Bool = false) {
        self.name = name
        self.isDone = isDone
        self.creationDate = creationDate
        self.dueDate = dueDate
    }

    var id = UUID()

    static func == (lhs: Todo, rhs: Todo) -> Bool {
        lhs.id == rhs.id
    }
}
