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
            if _lastColor == nil,
               let defaultsValue = defaults.object(forKey: "lastColor") as? String {
                Log.info("No last colour. Defaults value: \(defaultsValue)")
                _lastColor = .init(rawValue: defaultsValue)
            } else {
                Log.info("Last colour: \(_lastColor)")
            }

            return _lastColor ?? .gray
        }
        set {
            Log.info("Setting last colour to \(newValue)")
            _lastColor = newValue
            defaults.set(newValue.rawValue, forKey: "lastColor")
        }
    }
    private var _lastColor: PossibleColours?

    @Published var showTodoEditPopup: Bool = false
    @Published var todoToEdit: Todo?
}
