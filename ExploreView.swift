//
//  ExploreView.swift
//  Roami
//
//  The Explore tab: search field, a horizontally-scrolling "Trending
//  Destinations" carousel, and a two-column "Explore the World" grid.
//
//  Assumes this view is embedded as one tab of a parent TabView that
//  also hosts Home and My Trips (per the Hi-Fi's bottom tab bar) —
//  the tab bar itself isn't built here to keep this screen self-contained.
//

import SwiftUI

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @EnvironmentObject private var favorites: FavoritesStore
    @EnvironmentObject private var navigation: AppNavigation
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ExploreSearchBarView(text: $viewModel.searchText, isFocused: $isSearchFocused)

                    if viewModel.searchText.isEmpty {
                        trendingSection
                    }

                    exploreGridSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(RoamiTheme.background.ignoresSafeArea())
            .navigationDestination(for: Destination.self) { destination in
                DestinationDetailView(destination: destination)
            }
        }
        .onAppear { viewModel.loadDestinations() }
        .onChange(of: navigation.focusExploreSearch) {
            // Home's "+" button requests focus; consume the request so it
            // doesn't re-fire the next time this tab appears.
            guard navigation.focusExploreSearch else { return }
            isSearchFocused = true
            navigation.focusExploreSearch = false
        }
        .task(id: viewModel.searchText) {
            // Debounced global lookup: waits out rapid typing (the task is
            // cancelled and restarted on every keystroke), then searches
            // Wikipedia so any country/city can be found.
            guard !viewModel.searchText.isEmpty else { return }
            try? await Task.sleep(for: .seconds(0.4))
            guard !Task.isCancelled else { return }
            await viewModel.searchGlobalDestination()
        }
    }

    // MARK: - Trending Destinations

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Trending Destinations")
                    .font(.headline)
                    .foregroundStyle(RoamiTheme.deepGreen)
                Spacer()
                Button("See all") { /* navigate to full trending list */ }
                    .font(.subheadline)
                    .foregroundStyle(RoamiTheme.sageGreen)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.trending) { destination in
                        NavigationLink(value: destination) {
                            DestinationCardView(
                                destination: destination,
                                style: .compact,
                                isPinned: favorites.isPinned(destination)
                            ) {
                                favorites.toggle(destination)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Explore the World

    private var exploreGridSection: some View {
        // Two-column staggered "masonry" layout per the Hi-Fi: items
        // alternate between the columns, and card heights alternate
        // tall/short in opposite phase per column so the columns
        // interlock (left: tall, short, ... / right: short, tall, ...).
        let items = viewModel.filteredExploreGrid
        let left = items.enumerated().filter { $0.offset.isMultiple(of: 2) }.map(\.element)
        let right = items.enumerated().filter { !$0.offset.isMultiple(of: 2) }.map(\.element)

        return VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.searchText.isEmpty ? "Explore the World" : "Results")
                .font(.headline)
                .foregroundStyle(RoamiTheme.deepGreen)

            if items.isEmpty {
                Text("No destinations match \"\(viewModel.searchText)\"")
                    .font(.footnote)
                    .foregroundStyle(RoamiTheme.sageGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
            } else {
                HStack(alignment: .top, spacing: 12) {
                    gridColumn(left, tallOnEven: true)
                    gridColumn(right, tallOnEven: false)
                }
            }
        }
    }

    private func gridColumn(_ destinations: [Destination], tallOnEven: Bool) -> some View {
        VStack(spacing: 12) {
            ForEach(Array(destinations.enumerated()), id: \.element.id) { index, destination in
                NavigationLink(value: destination) {
                    DestinationCardView(
                        destination: destination,
                        style: .grid,
                        isTall: index.isMultiple(of: 2) == tallOnEven,
                        isPinned: favorites.isPinned(destination)
                    ) {
                        favorites.toggle(destination)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }

}

#Preview {
    ExploreView()
        .environmentObject(FavoritesStore())
        .environmentObject(AppNavigation())
}
