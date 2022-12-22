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
    case drag
}

let NWSECursor = """
/System/Library/Frameworks/WebKit.framework/Versions/Current/\
Frameworks/WebCore.framework/Resources/northWestSouthEastResizeCursor.png
"""

let NESWCursor = """
/System/Library/Frameworks/WebKit.framework/Versions/A/Frameworks/\
WebCore.framework/Versions/A/Resources/northEastSouthWestResizeCursor.png
"""

class DraggableResizableView: NSView {

    private let resizableArea: CGFloat = 5

    var delegate: DraggableResizableViewDelegate?

    private var cursorPosition: CornerBorderPosition = .drag

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
        // send the end message to the delegate
        if mouseIsDragging {
            mouseIsDragging = false
            delegate?.didEndDragging(with: event, cursorAt: cursorPosition)
        }

        self.cursorPosition = .drag
    }

    override func mouseMoved(with event: NSEvent) {
        let locationInView = convert(event.locationInWindow, from: nil)
        self.cursorPosition = self.cursorCornerBorderPosition(locationInView)
    }

    var mouseIsDragging: Bool = false
    override func mouseDragged(with event: NSEvent) {

        // send the start message to the delegate
        if !mouseIsDragging {
            mouseIsDragging = true
            delegate?.didStartDragging(with: event, cursorAt: cursorPosition)
        }

        let deltaX = event.deltaX
        let deltaY = event.deltaY

        let oldframe = self.frame // backup, for delegate purposes
        var newFrame = self.frame

        // vertical axis
        switch cursorPosition {
        case .top, .topLeft, .topRight:
            newFrame.size.height -= deltaY
        case .bottom, .bottomLeft, .bottomRight:
            newFrame.size.height += deltaY
            newFrame.origin.y -= deltaY
        default: break
        }

        // horizontal axis
        switch cursorPosition {
        case .left, .topLeft, .bottomLeft:
            newFrame.size.width -= deltaX
            newFrame.origin.x += deltaX
        case .right, .topRight, .bottomRight:
            newFrame.size.width += deltaX
        default: break
        }

        // none case
        if cursorPosition == .drag {
            newFrame.origin.x += deltaX
            newFrame.origin.y -= deltaY
        }

        // ask the delegate for the rect that it should resize to
        // if it returns nil, then do not resize.
        // if no delegate exists, it defaults to resizing to the proposed rect
        guard let finalFrame = delegate?.rectToSizeTo(for: event,
                                                      cursorAt: cursorPosition,
                                                      from: oldframe,
                                                      withProposal: newFrame)
        else { return }

        // inform the delegate that the view will resize
        delegate?.willResizeView(for: event,
                                 cursorAt: cursorPosition,
                                 from: oldframe,
                                 to: finalFrame)

        // resize the view, then inform the delegate that the view did resize
        self.frame = finalFrame
        delegate?.didResizeView(for: event,
                                cursorAt: cursorPosition,
                                from: oldframe,
                                to: finalFrame)

        self.repositionView()
    }

    @discardableResult
    func cursorCornerBorderPosition(_ locationInView: CGPoint) -> CornerBorderPosition {

        var cursor: CornerBorderPosition = .drag

        let isTop = self.bounds.height - locationInView.y < resizableArea
        let isBottom = locationInView.y < resizableArea
        let isLeading = locationInView.x < resizableArea
        let isTrailing = self.bounds.width - locationInView.x < resizableArea

        if isBottom {
            cursor = .bottom
            if isLeading {
                cursor = .bottomLeft
            } else if isTrailing {
                cursor = .bottomRight
            }
        } else if isTop {
            cursor = .top
            if isLeading {
                cursor = .topLeft
            } else if isTrailing {
                cursor = .topRight
            }
        } else if isLeading {
            cursor = .left
        } else if isTrailing {
            cursor = .right
        }

        return cursor
    }

    func setCursor() {
        var cursor: NSCursor = .arrow

        switch self.cursorPosition {
        case .bottomRight, .topLeft:
            cursor = .init(image: NSImage(byReferencingFile: NWSECursor)!,
                           hotSpot: NSPoint(x: 8, y: 8))
        case .bottomLeft, .topRight:
            cursor = .init(image: NSImage(byReferencingFile: NESWCursor)!,
                           hotSpot: NSPoint(x: 8, y: 8))
        case .top, .bottom:
            cursor = .resizeUpDown
        case .left, .right:
            cursor = .resizeLeftRight
        case .drag:
            cursor = .openHand
        }

        // TODO: Actually do things with the cursor
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

protocol DraggableResizableViewDelegate: AnyObject {

    /// Asks the delegate for the cursor that should be displayed given the location of the
    /// cursor, the calculated position, and the default suggested cursor.
    /// - Parameters:
    ///   - locationInView: The location of the cursor in the view's coordinate system
    ///   - calculatedPosition: The ``CornerBorderPosition`` of the mouse
    ///   - suggestedCursor: The suggested cursor, based on the `calculatedPosition`
    /// - Returns: The cursor to set. Return `NSCursor.arrow` for the default cursor.
    func cursorForPosition(locationInView: CGPoint,
                           calculatedPosition: CornerBorderPosition,
                           suggestedCursor: NSCursor) -> NSCursor

    /// Asks the delegate if the view should be resized by the user's drag action
    /// - Parameters:
    ///   - event: The event for the user's drag action
    ///   - cursorPosition: The corner or edge that the user is trying to drag
    ///   - oldRect: The current `NSRect` of the view
    ///   - newRect: The new, proposed resize of the view's `NSRect`
    /// - Returns: The NSRect that the view should resize to, or nil if it should not resize at all
    func rectToSizeTo(for event: NSEvent,
                      cursorAt cursorPosition: CornerBorderPosition,
                      from oldRect: NSRect,
                      withProposal newRect: NSRect) -> NSRect?

    /// Tells the delegate that the view is going to be resized by the user's drag action.
    ///
    /// Called after ``rectToSizeTo(for:cursorAt:from:withProposal:)-4kfu7``,
    /// before ``didResizeView(for:cursorAt:from:to:)-54yxd``
    ///
    /// - Parameters:
    ///   - event: The event for the user's drag action
    ///   - cursorPosition: The corner or edge that the user is trying to drag
    ///   - oldRect: The current `NSRect` of the view
    ///   - newRect: The new resize of the view's `NSRect`
    func willResizeView(for event: NSEvent,
                        cursorAt cursorPosition: CornerBorderPosition,
                        from oldRect: NSRect,
                        to newRect: NSRect)

    /// Tells the delegate that the view has been resized by the user's drag action.
    ///
    /// Called after ``willResizeView(for:cursorAt:from:to:)-3npf5``
    ///
    /// - Parameters:
    ///   - event: The event for the user's drag action
    ///   - cursorPosition: The corner or edge that the user is trying to drag
    ///   - oldRect: The previous `NSRect` of the view
    ///   - newRect: The new size of the view's `NSRect`
    func didResizeView(for event: NSEvent,
                       cursorAt cursorPosition: CornerBorderPosition,
                       from oldRect: NSRect,
                       to newRect: NSRect)

    /// Tells the delegate that the user has started dragging. This function runs before
    /// ``shouldResizeView(for:cursorAt:from:to:)-63m5m`` and other delegate functions.
    /// - Parameters:
    ///   - event: The event for the user's drag action
    ///   - cursorPosition: The position of the cursor at the start of the drag action
    func didStartDragging(with event: NSEvent,
                          cursorAt cursorPosition: CornerBorderPosition)

    /// Tells the delegate that the user has ended dragging. This function runs after
    /// ``didResizeView(for:cursorAt:from:to:)-25du4`` and other delegate functions.
    /// - Parameters:
    ///   - event: The event for the user's drag action
    ///   - cursorPosition: The position of the cursor at the end of the drag action
    func didEndDragging(with event: NSEvent,
                        cursorAt cursorPosition: CornerBorderPosition)
}

// default implementations
extension DraggableResizableViewDelegate {
    func cursorForPosition(locationInView: CGPoint,
                           calculatedPosition: CornerBorderPosition,
                           suggestedCursor: NSCursor) -> NSCursor { suggestedCursor }
    func rectToSizeTo(for event: NSEvent,
                      cursorAt cursorPosition: CornerBorderPosition,
                      from oldRect: NSRect,
                      withProposal newRect: NSRect) -> NSRect? { newRect }
    func willResizeView(for event: NSEvent,
                        cursorAt cursorPosition: CornerBorderPosition,
                        from oldRect: NSRect,
                        to newRect: NSRect) {}
    func didResizeView(for event: NSEvent,
                       cursorAt cursorPosition: CornerBorderPosition,
                       from oldRect: NSRect,
                       to newRect: NSRect) {}

    func didStartDragging(with event: NSEvent,
                          cursorAt cursorPosition: CornerBorderPosition) {}

    func didEndDragging(with event: NSEvent,
                        cursorAt cursorPosition: CornerBorderPosition) {}
}
