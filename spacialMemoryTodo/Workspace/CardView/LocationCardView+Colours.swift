//
//  LocationCardView+Colours.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 21/12/22.
//

import SwiftUI

extension LocationCardView {

    enum PossibleColours: String, CaseIterable {
        case blue = "blue"
        case purple = "purple"
        case pink = "pink"
        case red = "red"
        case orange = "orange"
        case yellow = "yellow"
        case green = "green"
        case gray = "gray"

        static let allCases: [LocationCardView.PossibleColours] = [
            .blue, .purple, .pink, .red, .orange, .yellow, .green, .gray
        ]
    }

    static var swiftColours: [PossibleColours: Color] = [
        .blue: .blue,
        .purple: .purple,
        .pink: .pink,
        .red: .red,
        .orange: .orange,
        .yellow: .yellow,
        .green: .green,
        .gray: .gray,
    ]

    static var lightColours: [PossibleColours: NSColor] = [
        .blue: .white,
        .purple: .white,
        .pink: .white,
        .red: .white,
        .orange: .white,
        .yellow: .white,
        .green: .white,
        .gray: .white,
    ]

    static var darkColours: [PossibleColours: NSColor] = [
        .blue: .white,
        .purple: .white,
        .pink: .white,
        .red: .white,
        .orange: .white,
        .yellow: .white,
        .green: .white,
        .gray: .white,
    ]
}
