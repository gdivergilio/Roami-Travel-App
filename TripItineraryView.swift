//
//  TripItineraryView.swift
//  Roami
//
//  Day-by-day travel plan for an upcoming trip, pushed from the
//  Upcoming Trips cards on My Trips. Includes the safety angle: an
//  advisory banner sits above the itinerary reminding the traveler to
//  review conditions before departure.
//
//  The plans are made-up sample data keyed by trip name; swap for a
//  real itinerary service later.
//

import SwiftUI

struct TripItineraryView: View {
    @Environment(\.dismiss) private var dismiss

    let trip: Trip

    private struct ItineraryDay: Identifiable {
        let id = UUID()
        let day: Int
        let title: String
        let detail: String
    }

    private static let plans: [String: [(String, String)]] = [
        "Iceland": [
            ("Arrive in Reykjavik", "Check in, stroll the harbor and soak in the Blue Lagoon"),
            ("Golden Circle", "Þingvellir National Park, Geysir hot springs and Gullfoss falls"),
            ("South Coast", "Seljalandsfoss and Skógafoss waterfalls, walk behind the falls"),
            ("Vík and beyond", "Black sand beaches at Reynisfjara and the Dyrhólaey arch"),
            ("Glacier lagoon", "Icebergs at Jökulsárlón and Diamond Beach"),
            ("Back to Reykjavik", "Souvenir shopping and a farewell dinner downtown")
        ],
        "Costa Rica": [
            ("Arrive in San José", "Settle in and explore the Central Market"),
            ("Monteverde", "Cloud forest hike among hanging bridges"),
            ("Adventure day", "Zip-lining over the canopy and a coffee farm tour"),
            ("La Fortuna", "Arenal volcano views and evening hot springs"),
            ("Manuel Antonio", "Beach day and wildlife spotting in the national park")
        ]
    ]

    private var days: [ItineraryDay] {
        let plan = Self.plans[trip.name] ?? [
            ("Arrival", "Check in and get your bearings"),
            ("Explore", "See the highlights with a local guide"),
            ("Departure", "Last stroll and travel home")
        ]
        return plan.enumerated().map { index, entry in
            ItineraryDay(day: index + 1, title: entry.0, detail: entry.1)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                heroPhoto

                VStack(alignment: .leading, spacing: 2) {
                    Text(trip.name)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(RoamiTheme.deepGreen)
                    if let dates = trip.dates {
                        Text(dates)
                            .font(.subheadline)
                            .foregroundStyle(RoamiTheme.sageGreen)
                    }
                }

                advisoryBanner

                Text("Your Itinerary")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(RoamiTheme.deepGreen)
                    .padding(.top, 4)

                ForEach(days) { day in
                    dayCard(day)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(RoamiTheme.background.ignoresSafeArea())
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Explicit, always-visible way to leave the page (swipe-back
            // still works too).
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(RoamiTheme.deepGreen)
                }
            }
        }
    }

    private var heroPhoto: some View {
        Rectangle()
            .fill(RoamiTheme.sageGreen.opacity(0.25))
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .overlay {
                Image(trip.imageName)
                    .resizable()
                    .scaledToFill()
                    .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var advisoryBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 3) {
                Text("Advisory Update for Your Upcoming Trip")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(RoamiTheme.deepGreen)
                Text("Conditions can change before you depart — review the latest travel advisories for \(trip.name) on the destination's Safety tab.")
                    .font(.caption)
                    .foregroundStyle(RoamiTheme.sageGreen)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func dayCard(_ day: ItineraryDay) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(day.day)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(RoamiTheme.sageGreen, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text("Day \(day.day): \(day.title)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(RoamiTheme.deepGreen)
                Text(day.detail)
                    .font(.caption)
                    .foregroundStyle(RoamiTheme.sageGreen)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

#Preview {
    NavigationStack {
        TripItineraryView(
            trip: Trip(name: "Iceland", dates: "June 15th- June 27th", riskLevel: .low, imageName: "trip-iceland")
        )
    }
}
