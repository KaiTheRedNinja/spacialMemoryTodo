//
//  CardsView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI
import macAppBoilerplate
import Combine

class CardsView: NSScrollView {

    var cards: [LocationCardView] = []
    var currentlySelectedLocation: Location.ID?
    var isCurrentlyDraggingCard: Bool = false

    var tabManager: TabManager
    var tabManagerCancellable: AnyCancellable!

    var tabContent: MainTabContent?
    var tabContentCancellable: AnyCancellable?

    var locations: [Location] {
        if let tabContent {
            return tabContent.locations
        }

        if let tabContent = tabManager.selectedTabItem() as? MainTabContent {
            self.tabContent = tabContent
            self.tabContentCancellable = tabContent.objectWillChange.sink {
                self.updateData()
            }
            return tabContent.locations
        }

        return []
    }

    init(frame frameRect: NSRect, tabManager: TabManager) {
        self.tabManager = tabManager
        super.init(frame: frameRect)
        self.tabManagerCancellable = tabManager.objectWillChange.sink {
            self.updateData()
        }
        self.hasVerticalScroller = true
        self.hasHorizontalScroller = true
        self.autohidesScrollers = true
        self.documentView = NSView(frame: frameRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.systemGray.cgColor
        locationsToCards()
        frameCards()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateData() {
        self.locationsToCards()
        self.frameCards()
        self.scrollToSelectedCard(animate: true)
    }

    func locationsToCards() {
        // iterate over locations and see if they have a corresponding card, add the location if otherwise
        let cardLocations = cards.map { $0.location }
        for (index, location) in locations.enumerated() where !cardLocations.contains(location) {
            let newCard = LocationCardView(location: location)
            newCard.cardsView = self
            cards.insert(newCard, at: index)
        }

        // iterate over cards and see if they have a corresponding location, remove the card if otherwise
        var newCards = cards
        for (index, card) in cards.enumerated() where !locations.contains(card.location) {
            newCards.remove(at: index)
        }
        cards = newCards
    }

    let minCardDistanceFromEdge: CGFloat = 300

    func frameCards(animate: Bool = false) {
        // find the coordinates closest to each edge. This will serve as the reference points.
        // since we want the effect of infinite space, the edges of the document view must always
        // be `cardDistanceFromEdge` away from the nearest card.

        var edges: [Edge.Edges: CGFloat] = [:]

        for card in cards {
            let cardEdges: [Edge.Edges: CGFloat] = [
                .top: card.location.rect.minY, // CGFloat's top is actually the minimum since going down the screen Y gets bigger
                .bottom: card.location.rect.maxY,
                .leading: card.location.rect.minX,
                .trailing: card.location.rect.maxX,
            ]

            // replace the values in edges where the value is larger/smaller
            for (edge, value) in cardEdges where isBetterEdge(edge: edge, value: value) {
                edges[edge] = value
            }

            func isBetterEdge(edge: Edge.Edges, value: CGFloat) -> Bool {
                (   // if its top or leading, then the new value must be smaller
                    (edge == .top || edge == .leading) && (edges[edge] ?? 0) >= value
                ) || ( // if its bottom or trailing, then the new value must be larger
                    (edge == .bottom || edge == .trailing) && (edges[edge] ?? 0) <= value
                )
            }
        }

        // using the size of the content view, calculate the card distance from edge for height and width
        let cardsWidth = (edges[.trailing] ?? 0) - (edges[.leading] ?? 0)
        let cardsHeight = (edges[.bottom] ?? 0) - (edges[.top] ?? 0)

        let cardXDistance = max(minCardDistanceFromEdge, (contentView.frame.width-cardsWidth)/2)
        let cardYDistance = max(minCardDistanceFromEdge, (contentView.frame.height-cardsHeight)/2)

        // reframe the origin of all frames by (`cardDistanceFromEdge - edges[.top]`, `cardDistanceFromEdge - edges[.leading]`)
        let leadingEdgeOffset = cardXDistance - (edges[.leading] ?? 0)
        let topEdgeOffset = cardYDistance - (edges[.top] ?? 0)
        let offsetSize = CGSize(width: leadingEdgeOffset, height: topEdgeOffset)

        for card in cards {
            // if the card is not yet in the document view, add it
            if card.superview != documentView {
                documentView?.addSubview(card)
            }

            let origin = CGPoint(from: card.location.rect.origin, offsetBy: offsetSize)
            let size = card.location.rect.size

            if animate {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.2
                    card.animator().frame = .init(origin: origin, size: size)
                }
            } else {
                // fix the card's rect
                card.frame = .init(origin: origin, size: size)
            }
        }

        // set the document view's frame
        let newWidth = (edges[.trailing] ?? 0) + offsetSize.width + cardXDistance
        let newHeight = (edges[.bottom] ?? 0) + offsetSize.height + cardYDistance

        if animate {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                documentView?.animator().frame.size = .init(width: newWidth,
                                                            height: newHeight)
            }
        } else {
            documentView?.frame.size = .init(width: newWidth,
                                             height: newHeight)
        }
    }

    func scrollToSelectedCard(animate: Bool = false) {
        // Continue only if a card is not being dragged, document view exists,
        // a location has been selected, and that location has a card
        guard !isCurrentlyDraggingCard, let documentView,
              let selectedLocation = tabContent?.selectedLocation,
              selectedLocation.id != currentlySelectedLocation,
              let cardForLocation = cards.first(where: { $0.location == selectedLocation })
        else { return }

        let container: NSRect = documentView.frame  // the NSRect defining how large the bounding box is
        let card: NSRect = cardForLocation.frame    // the NSRect defining where the card is
        let lens: NSRect = self.visibleRect         // the NSRect defining what is visible

        // Calculate the center point of the card
        let cardCenterX = card.origin.x + (card.size.width / 2)
        let cardCenterY = card.origin.y + (card.size.height / 2)

        // Calculate the distance of the center point of the lens away from any given origin
        let lensCenterX = lens.size.width / 2
        let lensCenterY = lens.size.height / 2

        // Calculate the ideal X and Y positions of the lens
        let idealLensCenterX = cardCenterX - lensCenterX
        let idealLensCenterY = cardCenterY - lensCenterY

        // Calculate the maximum points that will be clipped to
        let maximumPoint = NSPoint(x: container.origin.x + container.width - lens.size.width,
                                   y: container.origin.y + container.height - lens.size.height)

        // Calculate the new origin of the lens so that its center is as close as possible to the center of the card
        // but make sure it does not exceed the bounds of the container
        let lensOriginX = max(container.origin.x,   // do not let the value go below the origin's value
                              min(idealLensCenterX, // the ideal position for the lens's origin to be
                                  maximumPoint.x))  // do not let the value go above the highest valid value
        let lensOriginY = max(container.origin.y,
                              min(idealLensCenterY,
                                  maximumPoint.y))

        // Update the origin of the lens
        // the scrollview will scroll so that the point specified in scroll(to:) is at the bottom-left corner of the scroll view
        if animate {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                self.contentView.animator().setBoundsOrigin(NSPoint(x: lensOriginX, y: lensOriginY))
            }
        } else {
            self.contentView.setBoundsOrigin(NSPoint(x: lensOriginX, y: lensOriginY))
        }

        // select the card internally, to prevent the view jumping around
        currentlySelectedLocation = selectedLocation.id
    }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        frameCards()
    }

    deinit {
        tabManagerCancellable.cancel()
        tabContentCancellable?.cancel()
    }
}

extension CGPoint {
    init(from originPoint: CGPoint, offsetBy offsetSize: CGSize) {
        self.init(x: originPoint.x + offsetSize.width,
                  y: originPoint.y + offsetSize.height)
    }
}

extension Edge {
    enum Edges: CaseIterable {
        case top
        case bottom
        case leading
        case trailing
    }
}

extension Dictionary where Key == Edge.Edges {
    var description: String {
        var string = "[\n"
        for (key, value) in self {
            string += "\t\(key): \(value)\n"
        }
        string += "]"
        return string
    }
}
