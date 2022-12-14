//
//  NavigatorSidebar.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate

class NavigatorSidebar: macAppBoilerplate.SidebarProtocol {

    init(popUpManager: PopUpManager) {
        self.popUpManager = popUpManager
    }

    var popUpManager: PopUpManager

    // no items needed since its only one view
    var items: [macAppBoilerplate.SidebarDockIcon] = []

    var isNavigatorSidebar: Bool = false

    // if sidebarType is inspector, then it should not show
    func showSidebarFor(sidebarType: SidebarType) -> Bool {
        return sidebarType == .navigator
    }

    func sidebarViewFor(selection: Int) -> AnyView {
        MainContentWrapper {
            ZStack {
                if self.isNavigatorSidebar {
                    SidebarNavigatorView(popUpManager: self.popUpManager)
                }
            }
        }
    }
}
