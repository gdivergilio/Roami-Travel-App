//
//  AppNavigation.swift
//  Roami
//
//  Cross-tab navigation intents that a single tab's view can't express on
//  its own — e.g. Home's "+" button needing to switch to Explore *and*
//  focus its search field. Shared via .environmentObject from RootTabView.
//

import Foundation
import Combine

@MainActor
final class AppNavigation: ObservableObject {
    @Published var selectedTab: RootTabView.Tab = .home
    @Published var focusExploreSearch: Bool = false

    /// Switches to Explore and focuses its search field, so the caller
    /// (e.g. Home's "+" button) can jump straight into pinning a new
    /// destination.
    func goToExploreSearch() {
        selectedTab = .explore
        focusExploreSearch = true
    }

    /// Switches to the My Trips tab (e.g. Profile's "See more..." link).
    func goToMyTrips() {
        selectedTab = .myTrips
    }
}
