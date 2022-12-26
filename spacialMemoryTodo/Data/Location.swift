//
//  Location.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import Foundation

class Location: Identifiable, Equatable, ObservableObject, Codable {
    @Published var name: String
    @Published var todos: [Todo]
    @Published var colour: PossibleColours

    // as it changes VERY often while moving, it cannot be published
    // for the sake of memory usage
    var rect: CGRect

    init(name: String,
         todos: [Todo],
         colour: PossibleColours = .gray,
         rect: CGRect = .defaultLocationCardSize) {
        self.name = name
        self.todos = todos
        self.colour = colour
        self.rect = rect
    }

    var id = UUID()

    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: Codable
    enum Keys: CodingKey {
        case name
        case todos
        case colour
        case rect
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(name, forKey: .name)
        try container.encode(todos, forKey: .todos)
        try container.encode(colour.rawValue, forKey: .colour)
        try container.encode(rect, forKey: .rect)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.todos = try container.decode([Todo].self, forKey: .todos)
        self.colour = .init(rawValue: try container.decode(String.self, forKey: .colour)) ?? .gray
        self.rect = try container.decode(CGRect.self, forKey: .rect)
    }
}

extension CGRect {
    static let defaultLocationCardSize: CGRect = CGRect(origin: .zero, size: .init(width: 100, height: 100))
}
