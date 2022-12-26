//
//  Location.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import Foundation

class Location: Identifiable, Equatable, ObservableObject {
    @Published var name: String
    @Published var todos: [Todo]
    @Published var colour: PossibleColours = .gray

    // as it changes VERY often while moving, it cannot be published
    // for the sake of memory usage
    var rect: CGRect

    init(name: String, todos: [Todo], rect: CGRect = .defaultLocationCardSize) {
        self.name = name
        self.todos = todos
        self.rect = rect
    }

    var id = UUID()

    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}

extension CGRect {
    static let defaultLocationCardSize: CGRect = CGRect(origin: .zero, size: .init(width: 100, height: 100))
}
