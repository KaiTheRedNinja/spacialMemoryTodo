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

    var body: some View {
        VStack {
            Text("HI main content here")
        }
        .onAppear {
            self.tabManager.openTab(tab: MainTabContent())
        }
    }
}
