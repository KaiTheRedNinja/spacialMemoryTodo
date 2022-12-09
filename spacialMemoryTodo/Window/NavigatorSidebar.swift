//
//  NavigatorSidebar.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate

class NavigatorSidebar: macAppBoilerplate.SidebarProtocol {

    // no items needed since its only one view
    var items: [macAppBoilerplate.SidebarDockIcon] = []

    // if sidebarType is inspector, then it should not show
    func showSidebarFor(sidebarType: SidebarType) -> Bool {
        return sidebarType == .navigator
    }

    func sidebarViewFor(selection: Int) -> AnyView {
        MainContentWrapper {
            NotesNavigatorView()
        }
    }
}
