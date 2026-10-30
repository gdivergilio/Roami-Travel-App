//
//  RootTabView.swift
//  Roami
//
//  The app's root navigation shell. Hosts the three main sections shown
//  in every Hi-Fi screenshot's bottom bar: Home, Explore, My Trips.
//
//  This should be the view your App's WindowGroup points at (i.e. what
//  shows after the splash/onboarding flow finishes, if you build that).
//
//  Framework note: plain SwiftUI `TabView` with `.tabItem`. No custom
//  tab bar UIKit hosting needed — the Hi-Fi's bar (icon + label, one
//  tinted "selected" state) is exactly what the native component gives
//  us for free, and it inherits Dynamic Type / accessibility / dark
//  mode behavior automatically.
//

import SwiftUI

struct RootTabView: View {
    enum Tab {
        case home, explore, myTrips
    }

    /// Shared pinned-destination state: Explore writes it, Home's globe
    /// and My Trips' Favorites read it.
    @StateObject private var favorites = FavoritesStore()

    /// Cross-tab navigation intents (e.g. Home's "+" jumping to Explore's
    /// search). Tab selection itself lives here so other tabs can drive it.
    @StateObject private var navigation = AppNavigation()

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            // Note: opaque tab bar styling uses the SwiftUI toolbarBackground
            // modifiers (below, per tab) — NOT UITabBar.appearance(), which
            // conflicts with the modern tab bar and can make it disappear.
            HomeView()
                .toolbarBackground(RoamiTheme.background, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.home)

            ExploreView()
                .toolbarBackground(RoamiTheme.background, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(Tab.explore)

            MyTripsView()
                .toolbarBackground(RoamiTheme.background, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .tabItem {
                    Label("My Trips", systemImage: "lightbulb")
                }
                .tag(Tab.myTrips)
        }
        .tint(RoamiTheme.deepGreen) // tab bar selection per the design's #455742
        .environmentObject(favorites)
        .environmentObject(navigation)
    }
}

#Preview {
    RootTabView()
}
