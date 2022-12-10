//
//  CardsContainerView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI

struct CardsContainerView: NSViewRepresentable {
    typealias NSViewType = CardsView

    func makeNSView(context: Context) -> CardsView {
        return CardsView(frame: .zero)
    }

    func updateNSView(_ nsView: CardsView, context: Context) {}
}
