//
//  Workspace.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate

class Workspace: macAppBoilerplate.WorkspaceProtocol {

    init(popUpManager: PopUpManager) {
        self.popUpManager = popUpManager
    }

    var popUpManager: PopUpManager

    func viewForWorkspace(tab: TabBarID) -> AnyView {
        MainContentWrapper {
            WorkspaceView(popUpManager: self.popUpManager)
        }
    }
}
