//
//  WorkspaceView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate

struct WorkspaceView: View {
    @EnvironmentObject
    var tabManager: TabManager

    @ObservedObject
    var popUpManager: PopUpManager

    var body: some View {
        VStack {
            CardsContainerView(tabManager: tabManager, popUpManager: popUpManager)
        }
        .sheet(isPresented: $popUpManager.showLocationEditPopup) {
            GroupBox {
                EditLocationPopUpView(tabManager: tabManager, popUpManager: popUpManager)
            }
        }
        .sheet(isPresented: $popUpManager.showTodoEditPopup) {
            GroupBox {
                EditTodoPopUpView(tabManager: tabManager, popUpManager: popUpManager)
            }
        }
    }
}
