//
//  PopUpManager.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 21/12/22.
//

import SwiftUI

var defaults = UserDefaults.standard

class PopUpManager: ObservableObject {
    @Published var showLocationEditPopup: Bool = false
    @Published var locationToEdit: Location?
    var lastColour: PossibleColours {
        get {
            // if there is no last colour, read it from user defaults
            if _lastColor == nil,
               let defaultsValue = defaults.object(forKey: "lastColor") as? String {
                _lastColor = .init(rawValue: defaultsValue)
            }

            return _lastColor ?? .gray
        }
        set {
            _lastColor = newValue
            defaults.set(newValue.rawValue, forKey: "lastColor")
        }
    }
    // cached version of the userDefaults, to avoid excessive reading
    private var _lastColor: PossibleColours?

    @Published var showTodoEditPopup: Bool = false
    @Published var todoToEdit: Todo?
}
