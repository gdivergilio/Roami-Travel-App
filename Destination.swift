//
//  Destination.swift
//  Roami
//
//  Core model backing both the "Trending Destinations" carousel and
//  the "Explore the World" grid on the Explore screen.
//

import Foundation

enum RiskLevel: String, Hashable {
    case low = "Low risk"
    case moderate = "Moderate risk"
    case high = "High risk"

    /// Symbol shown before the label, matches the Hi-Fi's triangle warning glyph.
    var systemImage: String {
        switch self {
        case .low: return "exclamationmark.triangle"
        case .moderate: return "exclamationmark.triangle"
        case .high: return "exclamationmark.triangle.fill"
        }
    }
}

struct Destination: Identifiable, Hashable {
    let id: UUID
    let name: String
    let country: String
    let imageURL: URL?
    /// Name of a bundled asset-catalog image; takes precedence over `imageURL`.
    let imageName: String?
    /// One-line description shown on the destination detail screen.
    let blurb: String?
    let riskLevel: RiskLevel?
    /// Center of the area map on safety-alert detail screens.
    let latitude: Double?
    let longitude: Double?
    var isPinned: Bool

    init(
        id: UUID = UUID(),
        name: String,
        country: String,
        imageURL: URL? = nil,
        imageName: String? = nil,
        blurb: String? = nil,
        riskLevel: RiskLevel? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        isPinned: Bool = false
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.imageURL = imageURL
        self.imageName = imageName
        self.blurb = blurb
        self.riskLevel = riskLevel
        self.latitude = latitude
        self.longitude = longitude
        self.isPinned = isPinned
    }
}

// MARK: - Sample data
// Placeholder catalog mirroring the Hi-Fi; swap for a real backend later.
// Shared by ExploreViewModel (listing) and FavoritesStore (initial pins).

extension Destination {
    static let sampleTrending: [Destination] = [
        Destination(name: "Santorini", country: "Greece", imageName: "explore-santorini",
                    blurb: "Whitewashed villages perched above the deep blue Aegean.",
                    riskLevel: .low, latitude: 36.393, longitude: 25.461),
        Destination(name: "Kyoto", country: "Japan", imageName: "explore-kyoto",
                    blurb: "A city where centuries of tradition meet quiet temple gardens.",
                    riskLevel: .moderate, latitude: 35.011, longitude: 135.768),
        Destination(name: "Patagonia", country: "Chile", imageName: "explore-patagonia",
                    blurb: "Wild granite peaks, glaciers, and endless open skies.",
                    riskLevel: .low, latitude: -51.253, longitude: -72.343),
        Destination(name: "Reykjavik", country: "Iceland", imageName: "explore-reykjavik",
                    blurb: "Colorful rooftops, geothermal pools and northern lights.",
                    riskLevel: .low, latitude: 64.147, longitude: -21.943),
        Destination(name: "Bali", country: "Indonesia", imageName: "explore-bali",
                    blurb: "Rice terraces, sea temples and surf under a tropical sun.",
                    riskLevel: .moderate, latitude: -8.409, longitude: 115.189)
    ]

    static let sampleExploreGrid: [Destination] = [
        Destination(name: "Amalfi Coast", country: "Italy", imageName: "explore-amalfi",
                    blurb: "Cliffside villages and lemon groves above the Tyrrhenian Sea.",
                    riskLevel: .low, latitude: 40.634, longitude: 14.603, isPinned: true),
        Destination(name: "Swiss Alps", country: "Switzerland", imageName: "explore-swiss-alps",
                    blurb: "Storybook villages beneath snow-capped alpine giants.",
                    riskLevel: .low, latitude: 46.020, longitude: 7.749, isPinned: true),
        Destination(name: "Shibuya", country: "Japan", imageName: "trip-tokyo",
                    blurb: "A city where futuristic innovation meets centuries of tradition.",
                    riskLevel: .moderate, latitude: 35.659, longitude: 139.700),
        Destination(name: "Marrakech", country: "Morocco", imageName: "explore-marrakech",
                    blurb: "A maze of souks, palaces, and gardens in ochre red.",
                    riskLevel: .moderate, latitude: 31.630, longitude: -7.989),
        Destination(name: "East Lansing", country: "United States", imageName: "explore-east-lansing",
                    blurb: "A classic college town on the banks of the Red Cedar River.",
                    riskLevel: .low, latitude: 42.737, longitude: -84.484),
        Destination(name: "Michigan State", country: "United States", imageName: "explore-michigan-state",
                    blurb: "Spartan pride, leafy quads and Big Ten energy — Go Green!",
                    riskLevel: .low, latitude: 42.719, longitude: -84.478),
        Destination(name: "Banff", country: "Canada", imageName: "trip-banff",
                    blurb: "Turquoise lakes beneath towering Rockies peaks.",
                    riskLevel: .low, latitude: 51.178, longitude: -115.571),
        Destination(name: "Lisbon", country: "Portugal", imageName: "explore-lisbon",
                    blurb: "Tiled facades, tram bells and golden Atlantic light.",
                    riskLevel: .low, latitude: 38.722, longitude: -9.139),
        Destination(name: "Rome", country: "Italy", imageName: "explore-rome",
                    blurb: "Ancient ruins and lively piazzas around every corner.",
                    riskLevel: .moderate, latitude: 41.903, longitude: 12.496),
        Destination(name: "Cape Town", country: "South Africa", imageName: "explore-cape-town",
                    blurb: "Where Table Mountain meets two oceans.",
                    riskLevel: .moderate, latitude: -33.925, longitude: 18.424)
    ]
}
