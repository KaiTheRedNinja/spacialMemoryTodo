//
//  PossibleColours.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 30/12/22.
//

import SwiftUI

enum PossibleColours: String, CaseIterable {
    case blue
    case purple
    case pink
    case red
    case orange
    case yellow
    case green
    case gray

    static let allCases: [PossibleColours] = [
        .blue, .purple, .pink, .red, .orange, .yellow, .green, .gray
    ]

    static var swiftColours: [PossibleColours: Color] = [
        .blue: .blue,
        .purple: .purple,
        .pink: .pink,
        .red: .red,
        .orange: .orange,
        .yellow: .yellow,
        .green: .green,
        .gray: .gray
    ]

    static var lightColours: [PossibleColours: NSColor] = [
        .blue: .init(red: 0.67, green: 0.80, blue: 0.94, alpha: 1.0),
        .purple: .init(red: 0.73, green: 0.65, blue: 0.87, alpha: 1.0),
        .pink: .init(red: 0.98, green: 0.76, blue: 0.80, alpha: 1.0),
        .red: .init(red: 0.94, green: 0.63, blue: 0.63, alpha: 1.0),
        .orange: .init(red: 0.98, green: 0.78, blue: 0.62, alpha: 1.0),
        .yellow: .init(red: 0.98, green: 0.91, blue: 0.62, alpha: 1.0),
        .green: .init(red: 0.70, green: 0.87, blue: 0.70, alpha: 1.0),
        .gray: .init(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.0)
    ]

    static var darkColours: [PossibleColours: NSColor] = [
        .blue: .init(red: 0.25, green: 0.47, blue: 0.79, alpha: 1.0),
        .purple: .init(red: 0.48, green: 0.30, blue: 0.64, alpha: 1.0),
        .pink: .init(red: 0.88, green: 0.43, blue: 0.57, alpha: 1.0),
        .red: .init(red: 0.77, green: 0.21, blue: 0.19, alpha: 1.0),
        .orange: .init(red: 0.89, green: 0.46, blue: 0.20, alpha: 1.0),
        .yellow: .init(red: 0.92, green: 0.78, blue: 0.20, alpha: 1.0),
        .green: .init(red: 0.28, green: 0.57, blue: 0.28, alpha: 1.0),
        .gray: .init(red: 0.56, green: 0.56, blue: 0.58, alpha: 1.0)
    ]
}
