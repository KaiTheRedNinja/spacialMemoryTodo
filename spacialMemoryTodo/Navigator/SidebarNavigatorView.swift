//
//  SidebarNavigatorView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate

struct SidebarNavigatorView: View {
    @EnvironmentObject
    var tabManager: TabManager

    @ObservedObject
    var popUpManager: PopUpManager

    var body: some View {
        VStack {
            OutlineView { _ in
                let view = NavigatorOutlineView()
                view.popUpManager = popUpManager
                return view
            }
        }
    }
}
