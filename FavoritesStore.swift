//
//  FavoritesStore.swift
//  Roami
//
//  App-wide pinned/favorited destinations, shared across tabs via
//  .environmentObject from RootTabView:
//   - Explore: the pin button on cards toggles membership
//   - My Trips: the Favorites section lists members
//   - Home: the PIN button shows members as pins on the globe
//
//  Destinations are matched by name because the sample catalog creates
//  fresh UUIDs on each load.
//

import SwiftUI
import Combine

@MainActor
final class FavoritesStore: ObservableObject {
    @Published var favorites: [Destination]

    init() {
        // Start with the destinations marked pinned in the sample catalog.
        favorites = Destination.sampleExploreGrid.filter(\.isPinned)
    }

    func isPinned(_ destination: Destination) -> Bool {
        favorites.contains { $0.name == destination.name }
    }

    func toggle(_ destination: Destination) {
        if let index = favorites.firstIndex(where: { $0.name == destination.name }) {
            favorites.remove(at: index)
        } else {
            favorites.append(destination)
        }
    }

    func destination(named name: String) -> Destination? {
        favorites.first { $0.name == name }
    }
}
