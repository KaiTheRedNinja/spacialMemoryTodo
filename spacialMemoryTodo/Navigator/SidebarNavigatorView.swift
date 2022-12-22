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

    var body: some View {
        VStack {
            OutlineView { _ in
                NavigatorOutlineView()
            }
        }
        .onAppear {
            self.tabManager.openTab(tab: MainTabContent())
        }
    }
}

struct NotesNavigatorView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarNavigatorView()
    }
}
