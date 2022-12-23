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
    var locationCancellable: AnyCancellable!

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
    /// Button for adding todos
    var addTodoButton: NSButton!
    /// Text field for displaying the number of Todos for the the Location
    var count: NSTextField!

    /// An outlineView to show the list of Todos
    var outlineView: LocationCardOutlineView!

    init(frame: CGRect = .defaultLocationCardSize, location: Location) {
        // setup the location and the view itself
        self.location = location
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

        // set up and configure the add todo Button
        self.addTodoButton = NSButton(image: NSImage(systemSymbolName: "plus", accessibilityDescription: nil)!,
                                      target: self,
                                      action: #selector(addTodo))
        self.addTodoButton.isBordered = false
        self.addSubview(addTodoButton)

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

        // set up the location cancellable. This has to be after setup
        // as it encapsulates `self` in a closure
        self.locationCancellable = self.location.objectWillChange.sink {
            self.title.stringValue = self.location.name
            self.count.stringValue = "\(self.location.todos.count)"
            outlineView.outlineView.reloadData()
            self.setBackgroundColour()
        }

        // run these to frame the objects correctly
        // and to make sure they're the right colours
        resizeSubviews(withOldSize: .zero)
        viewDidChangeEffectiveAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    func addTodo() {
        location.todos.append(.init(name: "Untitled Todo"))
        location.objectWillChange.send()
    }

    // some constants to manage the title's size
    let titleHeight: CGFloat = 25
    let titleOffset: CGFloat = 10
    let outlineOffset: CGFloat = 3
    // resize all subviews when the size of the view changes
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        // calculate the width needed by each view
        count.sizeToFit()
        let countWidth = count.frame.width
        let buttonWidth = titleHeight
        let titleWidth = frame.width - countWidth - buttonWidth - titleOffset*2

        let viewY = frame.height-titleHeight

        title.frame = .init(x: titleOffset,
                            y: viewY-titleOffset,
                            width: titleWidth,
                            height: titleHeight)
        addTodoButton.frame = .init(x: titleOffset + titleWidth,
                                    y: viewY,
                                    width: buttonWidth,
                                    height: buttonWidth-titleOffset)
        count.frame = .init(x: titleOffset + titleWidth + buttonWidth,
                            y: viewY-titleOffset,
                            width: countWidth,
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

        // set background and shadow colour
        setBackgroundColour()
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        // ensure that its a right mouse up event, or else its some event that we won't respond to.
        // though it says right mouse down, but it actually triggers when right mouse releases.
        guard event.type == .rightMouseDown else { return nil }

        // ensure that the right click is not within the outline view
        let locationInView = convert(event.locationInWindow, from: nil)
        guard !outlineView.view.frame.contains(locationInView) else { return nil }

        // create the menu. The title is not actually visible.
        let menu = NSMenu(title: "Right Click Menu")

        // add the items
        menu.addItem(NSMenuItem(title: "Edit", action: #selector(showEditPopup), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Delete Location", action: #selector(deleteLocation), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Spit Location", action: #selector(spitLocation), keyEquivalent: ""))

        return menu
    }

    @objc
    func showEditPopup() {
        cardsView.popUpManager.locationToEdit = location
        cardsView.popUpManager.showLocationEditPopup.toggle()
        cardsView.popUpManager.objectWillChange.send()
    }

    @objc
    func deleteLocation() {
        cardsView.tabContent?.locations.removeAll(where: { $0.id == location.id })
        cardsView.tabContent?.objectWillChange.send()
    }

    @objc
    func spitLocation() {
        Log.info(location.rect)
        Log.info(frame)
    }

    deinit {
        locationCancellable.cancel()
    }
}

extension LocationCardView: DraggableResizableViewDelegate {
    func cursorForPosition(locationInView: CGPoint,
                           calculatedPosition: CornerBorderPosition,
                           suggestedCursor: NSCursor) -> NSCursor {
        // if the mouse is not dragging, just use the default
        guard calculatedPosition == .drag else { return suggestedCursor }

        // if the cursor is in the title, let it drag
        if title.frame.contains(locationInView) {
            return suggestedCursor
        }
        // else, do not have the cursor
        return .arrow
    }

    func rectToSizeTo(for event: NSEvent,
                      cursorAt cursorPosition: CornerBorderPosition,
                      from oldRect: NSRect,
                      withProposal newRect: NSRect) -> NSRect? {

        if cursorPosition == .drag && NSCursor.current == .arrow {
            return nil
        }

        var returnedRect = newRect
        returnedRect.size = newRect.size.shrinkToNotSmallerThan(minSize: .minimumCardSize)

        // if the old rect's width or height is the same as the returned rect's width or height,
        // then reset the x and y value accordingly. This is to counteract the bug where if the card is at minimum
        // width/height, the card would start to move instead of not resizing.
        let widthIsSame = oldRect.width == returnedRect.width && cursorPosition != .drag
        let heightIsSame = oldRect.height == returnedRect.height && cursorPosition != .drag
        returnedRect.origin = .init(x: widthIsSame ? oldRect.minX : returnedRect.minX,
                                    y: heightIsSame ? oldRect.minY : returnedRect.minY)

        return returnedRect
    }

    func didResizeView(for event: NSEvent,
                       cursorAt cursorPosition: CornerBorderPosition,
                       from oldRect: NSRect,
                       to newRect: NSRect) {
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

        cardsView.calculateCardFrames()
    }

    func didStartDragging(with event: NSEvent, cursorAt cursorPosition: CornerBorderPosition) {
        cardsView.isCurrentlyDraggingCard = true
    }

    func didEndDragging(with event: NSEvent, cursorAt cursorPosition: CornerBorderPosition) {
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
