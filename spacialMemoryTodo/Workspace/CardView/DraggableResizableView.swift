//
//  DraggableResizableView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 11/12/22.
//

import Cocoa

enum CornerBorderPosition {
    case topLeft, topRight, bottomRight, bottomLeft
    case top, left, right, bottom
    case none
}

class DraggableResizableView: NSView {

    private let resizableArea: CGFloat = 5

    var delegate: DraggableResizableViewDelegate?

    private var cursorPosition: CornerBorderPosition = .none {
        didSet {
            switch self.cursorPosition {
            case .bottomRight, .topLeft:
                NSCursor(image:
                            NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/Current/Frameworks/WebCore.framework/Resources/northWestSouthEastResizeCursor.png")!,
                         hotSpot: NSPoint(x: 8, y: 8)).set()
            case .bottomLeft, .topRight:
                NSCursor(image:
                            NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/A/Frameworks/WebCore.framework/Versions/A/Resources/northEastSouthWestResizeCursor.png")!,
                         hotSpot: NSPoint(x: 8, y: 8)).set()
            case .top, .bottom:
                NSCursor.resizeUpDown.set()
            case .left, .right:
                NSCursor.resizeLeftRight.set()
            case .none:
                NSCursor.openHand.set()
            }
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.frame = self.frame.insetBy(dx: -2, dy: -2)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        trackingAreas.forEach({ removeTrackingArea($0) })

        addTrackingArea(NSTrackingArea(rect: self.bounds,
                                       options: [.mouseMoved,
                                                 .mouseEnteredAndExited,
                                                 .activeAlways],
                                       owner: self))
    }

    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
    }

    override func mouseDown(with event: NSEvent) {

        let locationInView = convert(event.locationInWindow, from: nil)

        self.cursorPosition = self.cursorCornerBorderPosition(locationInView)

    }

    override func mouseUp(with event: NSEvent) {

        self.cursorPosition = .none

    }

    override func mouseMoved(with event: NSEvent) {

        let locationInView = convert(event.locationInWindow, from: nil)

        self.cursorPosition = self.cursorCornerBorderPosition(locationInView)
    }

    override func mouseDragged(with event: NSEvent) {

        let deltaX = event.deltaX
        let deltaY = event.deltaY

        let oldframe = self.frame // backup, for delegate purposes
        var newFrame = self.frame

        switch cursorPosition {
        case .topLeft:
            newFrame.size.width -= deltaX
            newFrame.size.height -= deltaY
            newFrame.origin.x += deltaX
        case .bottomLeft:
            newFrame.origin.x += deltaX
            newFrame.origin.y -= deltaY
            newFrame.size.width -= deltaX
            newFrame.size.height += deltaY
        case .topRight:
            newFrame.size.width += deltaX
            newFrame.size.height -= deltaY
        case  .bottomRight:
            newFrame.origin.y -= deltaY
            newFrame.size.width += deltaX
            newFrame.size.height += deltaY
        case .top:
            newFrame.size.height -= deltaY
        case .bottom:
            newFrame.size.height += deltaY
            newFrame.origin.y -= deltaY
        case .left:
            newFrame.size.width -= deltaX
            newFrame.origin.x += deltaX
        case .right:
            newFrame.size.width += deltaX
        case .none:
            newFrame.origin.x += deltaX
            newFrame.origin.y -= deltaY
        }

        // ask the delegate for permission to resize the view
        // if no delegate exists, it defaults to true
        guard delegate?.shouldResizeView(for: event,
                                         cursorAt: cursorPosition,
                                         from: oldframe,
                                         to: newFrame) ?? true else { return }

        // inform the delegate that the view will resize
        delegate?.willResizeView(for: event,
                                 cursorAt: cursorPosition,
                                 from: oldframe,
                                 to: newFrame)

        // resize the view, then inform the delegate that the view did resize
        self.frame = newFrame
        delegate?.didResizeView(for: event,
                                cursorAt: cursorPosition,
                                from: oldframe,
                                to: newFrame)

        self.repositionView()
    }

    @discardableResult
    func cursorCornerBorderPosition(_ locationInView: CGPoint) -> CornerBorderPosition {

        if locationInView.x < resizableArea,
           locationInView.y < resizableArea {
            return .bottomLeft
        }
        if self.bounds.width - locationInView.x < resizableArea,
           locationInView.y < resizableArea {
            return .bottomRight
        }
        if locationInView.x < resizableArea,
           self.bounds.height - locationInView.y < resizableArea {
            return .topLeft
        }
        if self.bounds.height - locationInView.y < resizableArea,
           self.bounds.width - locationInView.x < resizableArea {
            return .topRight
        }
        if locationInView.x < resizableArea {
            return .left
        }
        if self.bounds.width - locationInView.x < resizableArea {
            return .right
        }
        if locationInView.y < resizableArea {
            return .bottom
        }
        if self.bounds.height - locationInView.y < resizableArea {
            return .top
        }

        return .none
    }

    private func repositionView() {

        guard let superView = superview else { return }

        if self.frame.minX < superView.frame.minX {
            self.frame.origin.x = superView.frame.minX
        }
        if self.frame.minY < superView.frame.minY {
            self.frame.origin.y = superView.frame.minY
        }

        if self.frame.maxX > superView.frame.maxX {
            self.frame.origin.x = superView.frame.maxX - self.frame.size.width
        }
        if self.frame.maxY > superView.frame.maxY {
            self.frame.origin.y = superView.frame.maxY - self.frame.size.height
        }
    }
}

protocol DraggableResizableViewDelegate {

    /// Asks the delegate if the view should be resized by the user's drag action
    /// - Parameters:
    ///   - event: The event for the user's drag action
    ///   - cursorPosition: The corner or edge that the user is trying to drag
    ///   - oldRect: The current `NSRect` of the view
    ///   - newRect: The new, proposed resize of the view's `NSRect`
    /// - Returns: If the view should continue with the resize (`true`) or cancel (`false`)
    func shouldResizeView(for event: NSEvent, cursorAt cursorPosition: CornerBorderPosition, from oldRect: NSRect, to newRect: NSRect) -> Bool

    /// Tells the delegate that the view is going to be resized by the user's drag action.
    ///
    /// Called after ``shouldResizeView(for:cursorAt:from:to:)``, before ``didResizeView(for:cursorAt:from:to:)``
    ///
    /// - Parameters:
    ///   - event: The event for the user's drag action
    ///   - cursorPosition: The corner or edge that the user is trying to drag
    ///   - oldRect: The current `NSRect` of the view
    ///   - newRect: The new resize of the view's `NSRect`
    func willResizeView(for event: NSEvent, cursorAt cursorPosition: CornerBorderPosition, from oldRect: NSRect, to newRect: NSRect)

    /// Tells the delegate that the view has been resized by the user's drag action.
    ///
    /// Called after ``willResizeView(for:cursorAt:from:to:)``
    ///
    /// - Parameters:
    ///   - event: The event for the user's drag action
    ///   - cursorPosition: The corner or edge that the user is trying to drag
    ///   - oldRect: The previous `NSRect` of the view
    ///   - newRect: The new size of the view's `NSRect`
    func didResizeView(for event: NSEvent, cursorAt cursorPosition: CornerBorderPosition, from oldRect: NSRect, to newRect: NSRect)
}

// default implementations

extension DraggableResizableViewDelegate {
    func shouldResizeView(for event: NSEvent,
                          cursorAt cursorPosition: CornerBorderPosition,
                          from oldRect: NSRect,
                          to newRect: NSRect) -> Bool { true }
    func willResizeView(for event: NSEvent,
                        cursorAt cursorPosition: CornerBorderPosition,
                        from oldRect: NSRect,
                        to newRect: NSRect) {}
    func didResizeView(for event: NSEvent,
                       cursorAt cursorPosition: CornerBorderPosition,
                       from oldRect: NSRect,
                       to newRect: NSRect) {}
}
