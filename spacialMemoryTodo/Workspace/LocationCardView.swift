//
//  LocationCardView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import Combine

class LocationCardView: DraggableResizableView {

    // the Location that the card takes care of
    var location: Location
    // the cancellable for the Location's listener
    var locationCancellable: AnyCancellable

    // the parent CardsView, for sending updates
    weak var cardsView: CardsView!

    // text field for displaying the Location's name
    var title: NSTextField!
    // text field for displaying the number of Todos for the the Location
    var count: NSTextField!

    // an outlineView to show the list of Todos
    var outlineView: LocationCardOutlineView!

    init(frame: CGRect = .defaultLocationCardSize, location: Location) {
        // setup the location, cancellable, and the view itself
        self.location = location
        self.locationCancellable = self.location.objectWillChange.sink {
        }
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false

        // give view a background and set itself as the DraggableResizeViewDelegate
        self.wantsLayer = true
        self.delegate = self

        // set up and configure the title TextField
        self.title = NSTextField(labelWithString: location.name)
        self.title.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
        self.title.maximumNumberOfLines = 1
        self.title.lineBreakMode = .byTruncatingMiddle
        self.addSubview(title)

        // set up and configure the count TextField
        self.count = NSTextField(labelWithString: "\(location.todos.count)")
        self.count.alignment = .right
        self.count.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
        self.addSubview(count)

        // set up the Todo outlineview
        let outlineView = LocationCardOutlineView()
        outlineView.location = location
        self.outlineView = outlineView
        self.addSubview(self.outlineView.view)

        // run these to frame the objects correctly
        // and to make sure they're the right colours
        resizeSubviews(withOldSize: .zero)
        viewDidChangeEffectiveAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let titleHeight: CGFloat = 25
    let titleOffset: CGFloat = 10
    let outlineOffset: CGFloat = 3
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        print("Resizing subviews")

        // calculate the width needed by the counter
        count.sizeToFit()
        let width = count.frame.width

        title.frame = .init(x: titleOffset,
                            y: frame.height-titleHeight-titleOffset,
                            width: frame.width-titleOffset*2-width,
                            height: titleHeight)
        count.frame = .init(x: titleOffset,
                            y: frame.height-titleHeight-titleOffset,
                            width: frame.width-titleOffset*2,
                            height: titleHeight)
        outlineView.view.frame = .init(x: outlineOffset,
                                       y: outlineOffset,
                                       width: frame.width-outlineOffset*2,
                                       height: frame.height-titleHeight-titleOffset-outlineOffset)
    }

    override func viewDidChangeEffectiveAppearance() {
        // textColor should automatically be whatever colour it needs to be
        title.textColor = .textColor
        count.textColor = .textColor

        if effectiveAppearance.name.rawValue.lowercased().contains("dark") {
            // dark mode
            layer?.backgroundColor = .init(gray: 0.3, alpha: 1)
        } else {
            // light mode
            layer?.backgroundColor = .init(gray: 0.8, alpha: 1)
        }
    }

    deinit {
        locationCancellable.cancel()
    }
}

extension LocationCardView: DraggableResizableViewDelegate {
    func didResizeView(for event: NSEvent, cursorAt cursorPosition: CornerBorderPosition, from oldRect: NSRect, to newRect: NSRect) {
        // Calculate the offset applied to location.rect to produce oldRect
        let xOffset = oldRect.origin.x - location.rect.origin.x
        let yOffset = oldRect.origin.y - location.rect.origin.y

        // Apply the same offset to newRect
        let offsetNewFrame = NSRect(
            x: newRect.origin.x - xOffset,
            y: newRect.origin.y - yOffset,
            width: newRect.size.width,
            height: newRect.size.height
        )

        // Set the location.rect to the new frame
        location.rect = offsetNewFrame

        cardsView.frameCards()
    }
}
