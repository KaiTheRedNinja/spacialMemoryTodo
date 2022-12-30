//
//  Location.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import Foundation

class Location: Identifiable, Equatable, ObservableObject, Codable {
    var name: String
    var todos: [Todo]
    var colour: PossibleColours

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

    func toggleTodoDone(withID id: Todo.ID) {
        // put the item at the end
        guard let index = todos.firstIndex(where: { $0.id == id }) else { return }

        let item = todos[index]
        item.isDone.toggle()
//        todos.remove(at: index)
//        todos.append(item)

        objectWillChange.send()
    }

    func removeTodo(withID id: Todo.ID) {
        todos.removeAll(where: { $0.id == id })
        objectWillChange.send()
    }

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

extension NSSize {
    static let minimumCardSize: NSSize = .init(width: 200, height: 125)

    func shrinkToNotSmallerThan(minSize: NSSize) -> NSSize {
        return .init(width: max(minSize.width, self.width),
                     height: max(minSize.height, self.height))
    }
}

extension CGRect {
    static let defaultLocationCardSize: CGRect = CGRect(origin: .zero, size: .minimumCardSize)
}
