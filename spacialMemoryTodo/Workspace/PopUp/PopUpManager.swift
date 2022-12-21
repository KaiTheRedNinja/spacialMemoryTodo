//
//  PopUpManager.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 21/12/22.
//

import SwiftUI

class PopUpManager: ObservableObject {
    @Published var showLocationEditPopup: Bool = false
    @Published var locationToEdit: Location?
}
