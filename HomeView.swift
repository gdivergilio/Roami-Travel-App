//
//  HomeView.swift
//  Roami
//
//  The Home tab: "Where to next?" header, an interactive 3D globe
//  (SceneKit — see GlobeSceneContainer.swift for why not MapKit), and
//  the circular "PIN" action button beneath it.
//
//  Replaces the earlier placeholder now that this screen is real.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var favorites: FavoritesStore
    @EnvironmentObject private var navigation: AppNavigation

    /// Pins currently shown on the globe — always mirrors the user's
    /// favorites. Kept as @State so pin identities stay stable across the
    /// per-frame position updates.
    @State private var pins: [GlobePin] = []

    @State private var pinScreenPositions: [UUID: CGPoint] = [:]
    @State private var pinVisibility: [UUID: Bool] = [:]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                Spacer(minLength: 16)

                globe
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 12)

                addDestinationButton
                    .padding(.top, 12)

                Spacer(minLength: 16)
            }
            .background(RoamiTheme.background.ignoresSafeArea())
            .navigationDestination(for: Destination.self) { destination in
                DestinationDetailView(destination: destination)
            }
            .onAppear { syncPins() }
            .onChange(of: favorites.favorites) {
                syncPins()
            }
        }
    }

    /// Rebuilds the globe pins from the favorites list — every favorite
    /// with coordinates gets a pin, always.
    private func syncPins() {
        pins = favorites.favorites.compactMap { destination in
            guard let latitude = destination.latitude, let longitude = destination.longitude else { return nil }
            return GlobePin(name: destination.name, latitude: latitude, longitude: longitude)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Welcome, Jean-Paul")
                    .font(.subheadline)
                    .foregroundStyle(RoamiTheme.sageGreen)
                Text("Where to next?")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(RoamiTheme.deepGreen)
            }
            Spacer()
            ProfileAvatarLink(size: 40)
        }
    }

    // MARK: - Globe + overlaid pin labels

    private var globe: some View {
        ZStack {
            GlobeSceneContainer(pins: pins) { positions, visible in
                pinScreenPositions = positions
                pinVisibility = visible
            }

            ForEach(pins) { pin in
                if pinVisibility[pin.id] == true, let position = pinScreenPositions[pin.id] {
                    // Name tags link to the destination's summary page.
                    if let destination = favorites.destination(named: pin.name) {
                        NavigationLink(value: destination) {
                            GlobePinLabelView(name: pin.name)
                        }
 
                        
                        .buttonStyle(.plain)
                        .position(position)
                    } else {
                        GlobePinLabelView(name: pin.name)
                            .position(position)
                            .allowsHitTesting(false)
                    }
                }
            }
        }
    }

    // MARK: - Add destination button

    /// Jumps to Explore's search so the user can find and pin a new
    /// destination without hunting for the tab themselves.
    private var addDestinationButton: some View {
        Button {
            navigation.goToExploreSearch()
        } label: {
            Image(systemName: "plus")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(RoamiTheme.deepGreen, in: Circle())
                .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environmentObject(FavoritesStore())
        .environmentObject(AppNavigation())
}
