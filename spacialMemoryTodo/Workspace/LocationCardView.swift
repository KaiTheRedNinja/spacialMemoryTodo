//
//  LocationCardView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI

class LocationCardView: DraggableResizableView {
    var location: Location

    var title: NSTextField!
    var count: NSTextField!

    var outlineView: LocationCardOutlineView!

    init(frame: CGRect = .defaultLocationCardSize, location: Location) {
        self.location = location
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false

        self.wantsLayer = true
        self.layer?.backgroundColor = .init(gray: 0.8, alpha: 1)

        self.title = NSTextField(labelWithString: location.name)
        self.title.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
        self.addSubview(title)

        self.count = NSTextField(labelWithString: "\(location.todos.count)")
        self.title.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
        self.addSubview(title)

        let outlineView = LocationCardOutlineView()
        outlineView.location = location

        self.outlineView = outlineView
        self.addSubview(self.outlineView.view)

        resizeSubviews(withOldSize: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let titleHeight: CGFloat = 25
    let titleOffset: CGFloat = 10
    let outlineOffset: CGFloat = 3
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        title.frame = .init(x: titleOffset,
                            y: frame.height-titleHeight-titleOffset,
                            width: frame.height-titleOffset*2,
                            height: titleHeight)
        outlineView.view.frame = .init(x: outlineOffset,
                                       y: outlineOffset,
                                       width: frame.width-outlineOffset*2,
                                       height: frame.height-titleHeight-titleOffset-outlineOffset)
    }
}
