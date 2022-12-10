//
//  LocationCardView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI

class LocationCardView: NSView {
    var location: Location

    init(frame: NSRect = .defaultLocationCardSize, location: Location) {
        self.location = location
        super.init(frame: frame)

        self.wantsLayer = true
        self.layer?.backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
