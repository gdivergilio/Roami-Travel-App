//
//  MyTripsView.swift
//  Roami
//
//  The My Trips tab: "My Trips" header with avatar, the user's travel
//  style, an Upcoming Trips section (with dates) and a pinned Favorites
//  section. Trip photos are bundled in Assets.xcassets ("trip-*").
//

import SwiftUI

struct MyTripsView: View {
    @EnvironmentObject private var favorites: FavoritesStore

    private let upcomingTrips: [Trip] = [
        Trip(name: "Iceland", dates: "June 15th- June 27th", riskLevel: .low, imageName: "trip-iceland"),
        Trip(name: "Costa Rica", dates: "October 2028", riskLevel: .low, imageName: "trip-costa-rica")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    header

                    Text("Based on your travel style • Active & Wellness")
                        .font(.footnote)
                        .foregroundStyle(RoamiTheme.sageGreen)

                    Text("Upcoming Trips")
                        .font(.headline)
                        .foregroundStyle(RoamiTheme.deepGreen)
                        .padding(.top, 8)

                    // Upcoming trips open their itinerary (with the safety
                    // advisory called out right on the card).
                    ForEach(upcomingTrips) { trip in
                        NavigationLink(value: trip) {
                            TripCardView(trip: trip, advisoryText: "Advisory update for your upcoming trip")
                        }
                        .buttonStyle(.plain)
                    }

                    favoritesHeader
                        .padding(.top, 16)

                    if favorites.favorites.isEmpty {
                        Text("No favorites yet — pin destinations on the Explore tab.")
                            .font(.footnote)
                            .foregroundStyle(RoamiTheme.sageGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    } else {
                        // Favorites open the destination's Explore page.
                        ForEach(favorites.favorites) { destination in
                            NavigationLink(value: destination) {
                                TripCardView(trip: Trip(
                                    name: destination.name,
                                    dates: nil,
                                    riskLevel: destination.riskLevel ?? .moderate,
                                    imageName: destination.imageName ?? "",
                                    imageURL: destination.imageURL
                                ))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(RoamiTheme.background.ignoresSafeArea())
            .navigationDestination(for: Trip.self) { trip in
                TripItineraryView(trip: trip)
            }
            .navigationDestination(for: Destination.self) { destination in
                DestinationDetailView(destination: destination)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("My Trips")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(RoamiTheme.deepGreen)

            ProfileAvatarLink()
        }
    }

    private var favoritesHeader: some View {
        HStack(spacing: 6) {
            Image(systemName: "pin.fill")
                .font(.subheadline)
                .foregroundStyle(RoamiTheme.rust)
                .rotationEffect(.degrees(-45))
            Text("Favorites")
                .font(.headline)
                .foregroundStyle(RoamiTheme.deepGreen)
        }
    }
}

// MARK: - Trip model
// (Also used by TripItineraryView for upcoming-trip plans.)

struct Trip: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let dates: String?
    let riskLevel: RiskLevel
    let imageName: String
    /// Remote photo fallback for destinations without a bundled image
    /// (e.g. favorites found via global search).
    var imageURL: URL? = nil
}

// MARK: - Trip card row

private struct TripCardView: View {
    let trip: Trip
    /// Optional safety callout shown along the bottom of the card
    /// (used for upcoming trips).
    var advisoryText: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                Group {
                    if !trip.imageName.isEmpty {
                        Image(trip.imageName)
                            .resizable()
                            .scaledToFill()
                    } else {
                        AsyncImage(url: trip.imageURL) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle().fill(RoamiTheme.sageGreen.opacity(0.25))
                        }
                    }
                }
                .frame(width: 64, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 3) {
                    RiskBadgeView(level: trip.riskLevel)
                    Text(trip.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(RoamiTheme.deepGreen)
                    if let dates = trip.dates {
                        Text(dates)
                            .font(.caption)
                            .foregroundStyle(RoamiTheme.sageGreen)
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(RoamiTheme.sageGreen)
            }

            if let advisoryText {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                    Text(advisoryText)
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(.orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .padding(12)
        .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

#Preview {
    MyTripsView()
        .environmentObject(FavoritesStore())
}
