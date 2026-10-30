//
//  SafetyAlertDetailView.swift
//  Roami
//
//  Detail screen for a single safety alert, pushed when an alert card
//  on the destination Safety tab is tapped. Per the Hi-Fi ("Protest
//  Activity" example): risk banner, area map, "What's Happening" and
//  "Impact" sections, a black View Full Details button, and a source
//  attribution line.
//

import SwiftUI
import MapKit

// MARK: - Model

/// One safety alert for a destination: the row content shown on the
/// Safety tab plus the expanded content for this detail screen.
struct SafetyAlert: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let message: String
    let systemImage: String
    let tint: Color
    /// Matches one of the filter chips; nil = general, shown under "All" only.
    let category: String?

    // Detail-screen content
    let riskTag: String
    let headline: String
    let lastUpdated: String
    let whatsHappening: String
    let impacts: [String]
}

// MARK: - Detail screen

struct SafetyAlertDetailView: View {
    let alert: SafetyAlert
    let destination: Destination

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                banner

                areaMap

                Text("What's Happening")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(RoamiTheme.deepGreen)
                Text(alert.whatsHappening)
                    .font(.subheadline)
                    .foregroundStyle(RoamiTheme.sageGreen)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Impact")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(RoamiTheme.deepGreen)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(alert.impacts, id: \.self) { impact in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                            Text(impact)
                        }
                        .font(.subheadline)
                        .foregroundStyle(RoamiTheme.sageGreen)
                    }
                }

                Button(action: { /* TODO: open the full advisory */ }) {
                    Text("View Full Details")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.top, 8)

                Text("Source: U.S. Department of State")
                    .font(.caption2)
                    .foregroundStyle(RoamiTheme.sageGreen)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(RoamiTheme.background.ignoresSafeArea())
        .navigationTitle(alert.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Banner

    private var banner: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: alert.systemImage)
                .font(.title)
                .foregroundStyle(alert.tint)

            VStack(alignment: .leading, spacing: 3) {
                Text(alert.riskTag)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(alert.tint)
                Text(alert.headline)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(RoamiTheme.deepGreen)
                Text("Last Updated \(alert.lastUpdated)")
                    .font(.caption2)
                    .foregroundStyle(RoamiTheme.sageGreen)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(alert.tint.opacity(0.18), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: Map

    @ViewBuilder
    private var areaMap: some View {
        if let latitude = destination.latitude, let longitude = destination.longitude {
            Map(initialPosition: .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
                )
            ))
            .frame(height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .allowsHitTesting(false) // decorative snapshot of the area, not interactive
        }
    }
}

#Preview {
    NavigationStack {
        SafetyAlertDetailView(
            alert: SafetyAlert(
                title: "Protest Activity",
                message: "",
                systemImage: "megaphone.fill",
                tint: RoamiTheme.rust,
                category: "Protest",
                riskTag: "High Risk",
                headline: "Political Protest Central Kyoto",
                lastUpdated: "May 17, 2026 at 8:00 Am",
                whatsHappening: "Protests are planned in central Kyoto from May 18 to May 20. Large gatherings are expected around Gion and Shijo Dori.",
                impacts: [
                    "Road closures and traffic delays",
                    "Crowded public transportation",
                    "Businesses may close early",
                    "Increased police presence"
                ]
            ),
            destination: Destination(
                name: "Kyoto",
                country: "Japan",
                imageName: "explore-kyoto",
                latitude: 35.011,
                longitude: 135.768
            )
        )
    }
}
