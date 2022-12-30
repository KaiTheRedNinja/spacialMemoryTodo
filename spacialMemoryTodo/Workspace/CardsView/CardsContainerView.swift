//
//  CardsContainerView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate

struct CardsContainerView: NSViewRepresentable {
    typealias NSViewType = CardsView

    @ObservedObject
    var tabManager: TabManager

    @ObservedObject
    var popUpManager: PopUpManager

    func makeNSView(context: Context) -> CardsView {
        return CardsView(frame: .zero, tabManager: tabManager, popUpManager: popUpManager)
    }

    func updateNSView(_ nsView: CardsView, context: Context) {}
}
