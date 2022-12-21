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

    @StateObject
    var popUpManager: PopUpManager = .init()

    var body: some View {
        VStack {
            CardsContainerView(tabManager: tabManager, popUpManager: popUpManager)
        }
        .sheet(isPresented: $popUpManager.showLocationEditPopup) {
            GroupBox {
                Text("HELLOOO")
            }
            .onAppear {
                print("Sheet was presented")
            }
        }
    }
}
