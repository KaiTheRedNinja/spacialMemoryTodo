//
//  LocationCardView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import Combine

class LocationCardView: DraggableResizableView {

    /// The Location that the card takes care of
    var location: Location
    /// The cancellable for the Location's listener
    var locationCancellable: AnyCancellable

    /// The parent CardsView, for sending updates
    weak var cardsView: CardsView!
    /// If the card has an outline
    var isOutlined: Bool = false {
        didSet {
            layer?.borderColor = NSColor.controlAccentColor.cgColor
            layer?.borderWidth = isOutlined ? 1 : 0
        }
    }

    /// Text field for displaying the Location's name
    var title: NSTextField!
    /// Text field for displaying the number of Todos for the the Location
    var count: NSTextField!

    /// An outlineView to show the list of Todos
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
        outlineView.view.wantsLayer = true
        self.addSubview(self.outlineView.view)

        // add corner radii to the card and outline view
        layer?.cornerRadius = 8
        outlineView.view.layer?.cornerRadius = 6

        // add a drop shadow
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 3
        shadow.shadowOffset = .init(width: 0, height: 0)
        shadow.shadowColor = .textColor
        self.shadow = shadow

        // run these to frame the objects correctly
        // and to make sure they're the right colours
        resizeSubviews(withOldSize: .zero)
        viewDidChangeEffectiveAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // some constants to manage the title's size
    let titleHeight: CGFloat = 25
    let titleOffset: CGFloat = 10
    let outlineOffset: CGFloat = 3
    // resize all subviews when the size of the view changes
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
        // textColor and shadow should automatically be whatever colour it needs to be
        title.textColor = .textColor
        count.textColor = .textColor
        shadow?.shadowColor = .textColor

        // set the background colour
        layer?.backgroundColor = effectiveAppearance.name.rawValue.lowercased().contains("dark") ?
            .init(gray: 0.3, alpha: 1) :
            .init(gray: 0.8, alpha: 1)
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        // ensure that its a right mouse up event, or else its some event that we won't respond to.
        // though it says right mouse down, but it actually triggers when right mouse releases.
        guard event.type == .rightMouseDown else { return nil }

        // create the menu. The title is not actually visible.
        let menu = NSMenu(title: "Right Click Menu")

        // add the items
        menu.addItem(NSMenuItem(title: "Edit", action: nil, keyEquivalent: ""))

        return menu
    }

    deinit {
        locationCancellable.cancel()
    }
}

extension LocationCardView: DraggableResizableViewDelegate {
    func rectToSizeTo(for event: NSEvent, cursorAt cursorPosition: CornerBorderPosition, from oldRect: NSRect, withProposal newRect: NSRect) -> NSRect? {
        var returnedRect = newRect
        returnedRect.size = newRect.size.shrinkToNotSmallerThan(minSize: .minimumCardSize)
        return returnedRect
    }

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

    func didStartDragging(with event: NSEvent, cursorAt cursorPosition: CornerBorderPosition) {
        print("Started dragging")
        cardsView.isCurrentlyDraggingCard = true
    }

    func didEndDragging(with event: NSEvent, cursorAt cursorPosition: CornerBorderPosition) {
        print("Ended dragging")
        cardsView.isCurrentlyDraggingCard = false
    }
}

extension NSSize {
    fileprivate static let minimumCardSize: NSSize = .init(width: 100, height: 100)

    func shrinkToNotSmallerThan(minSize: NSSize) -> NSSize {
        return .init(width: max(minSize.width, self.width),
                     height: max(minSize.height, self.height))
    }
}
