//
//  CardsView.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 9/12/22.
//

import SwiftUI

class CardsView: NSScrollView {

    var cards: [LocationCardView] = []

    var locations: [Location] = [
        .init(name: "test location", todos: [
            .init(name: "test todo"),
            .init(name: "test threedo")
        ], rect: .init(x: 0, y: 0, width: 100, height: 100)),
        .init(name: "test 2", todos: [
        ], rect: .init(x: 300, y: 300, width: 300, height: 100))
    ]

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.hasVerticalScroller = true
        self.hasHorizontalScroller = true
        self.autohidesScrollers = true
        self.documentView = NSView(frame: frameRect)
        locationsToCards()
        frameCards()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func locationsToCards() {
        // iterate over locations and see if they have a corresponding card, add the location if otherwise
        let cardLocations = cards.map { $0.location }
        for (index, location) in locations.enumerated() where !cardLocations.contains(location) {
            cards.insert(LocationCardView(location: location), at: index)
        }

        // iterate over cards and see if they have a corresponding location, remove the card if otherwise
        var newCards = cards
        for (index, card) in cards.enumerated() where !locations.contains(card.location) {
            newCards.remove(at: index)
        }
        cards = newCards
    }

    let minCardDistanceFromEdge: CGFloat = 100

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

            print("Card \(card.location.name) edges: \n\(cardEdges.description)")

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

            // fix the card's rect
            card.frame = .init(origin: .init(from: card.location.rect.origin, offsetBy: offsetSize),
                               size: card.location.rect.size)
        }

        // set the document view's frame
        let newWidth = max((edges[.trailing] ?? 0) + offsetSize.width + cardXDistance, self.contentView.frame.width)
        let newHeight = max((edges[.bottom] ?? 0) + offsetSize.height + cardYDistance, self.contentView.frame.height)
        documentView?.frame.size = .init(width: newWidth,
                                         height: newHeight)
    }

    override func resizeSubviews(withOldSize oldSize: NSSize) {
        frameCards()
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
