//
//  DestinationDetailView.swift
//  Roami
//
//  Destination detail screen, pushed when a card on Explore is tapped.
//  Per the Hi-Fi (the "Tokyo, Japan" example): country eyebrow + big
//  destination name + avatar, one-line blurb, a row of topic chips
//  (Summary selected by default), a "Let's Explore" hero photo, and a
//  stack of white content cards ("Must-Visit Areas" placeholders until
//  real content exists per topic).
//

import SwiftUI

struct DestinationDetailView: View {
    let destination: Destination

    private static let topics = ["Summary", "Safety", "Activities", "Stays", "Food"]

    @State private var selectedTopic: String
    @State private var selectedAlertFilter = "All"

    init(destination: Destination, initialTopic: String = "Summary") {
        self.destination = destination
        _selectedTopic = State(initialValue: initialTopic)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                topicChips

                if selectedTopic == "Safety" {
                    safetySection
                } else if selectedTopic == "Activities" {
                    activitiesSection
                } else if selectedTopic == "Stays" {
                    staysSection
                } else {
                    summarySection
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(RoamiTheme.background.ignoresSafeArea())
        .navigationDestination(for: SafetyAlert.self) { alert in
            SafetyAlertDetailView(alert: alert, destination: destination)
        }
    }

    // MARK: - Summary content

    @ViewBuilder
    private var summarySection: some View {
        Text("Let's Explore")
            .font(.title3.weight(.bold))
            .foregroundStyle(RoamiTheme.deepGreen)
            .padding(.top, 4)

        heroPhoto

        sectionCard(
            title: "Must-Visit Areas",
            subtitle: Self.neighborhoods[destination.name] ?? "The city's most-loved districts",
            systemImage: "location.fill"
        )
        sectionCard(
            title: "Local Cuisine",
            subtitle: Self.cuisine[destination.name] ?? "Taste the local specialties",
            systemImage: "fork.knife"
        )
        sectionCard(
            title: "Shopping",
            subtitle: Self.shopping[destination.name] ?? "Where to find luxury boutiques and trendy fashion",
            systemImage: "bag.fill"
        )
    }

    /// Sample per-destination content for the summary cards; replace with
    /// real data when a backend exists.
    private static let neighborhoods: [String: String] = [
        "Kyoto": "Gion, Arashiyama & Higashiyama",
        "Santorini": "Oia, Fira & Imerovigli",
        "Patagonia": "Puerto Natales & Torres del Paine",
        "Amalfi Coast": "Positano, Ravello & Amalfi",
        "Swiss Alps": "Zermatt, Grindelwald & Interlaken",
        "Shibuya": "Harajuku, Omotesandō & Ebisu",
        "Marrakech": "The Medina, Gueliz & the Kasbah",
        "East Lansing": "Downtown, Bailey & the Red Cedar riverfront",
        "Michigan State": "North Neighborhood, Brody & the River Trail",
        "Reykjavik": "Laugavegur, the Old Harbour & Grandi",
        "Bali": "Ubud, Canggu & Uluwatu",
        "Banff": "Banff Avenue, Lake Louise & Moraine Lake",
        "Lisbon": "Alfama, Bairro Alto & Belém",
        "Rome": "Trastevere, Monti & the Centro Storico",
        "Cape Town": "The V&A Waterfront, Bo-Kaap & Camps Bay"
    ]

    private static let cuisine: [String: String] = [
        "Kyoto": "Enjoy world famous sushi",
        "Shibuya": "Enjoy world famous sushi",
        "Santorini": "Fresh seafood and sunset tavernas",
        "Patagonia": "Lamb asado and Calafate berries",
        "Amalfi Coast": "Handmade pasta and lemon everything",
        "Swiss Alps": "Fondue, raclette and alpine chocolate",
        "Marrakech": "Tagines and mint tea in the souks",
        "East Lansing": "Late-night pizza and cozy cafés on Grand River Ave",
        "Michigan State": "MSU Dairy Store ice cream — a campus legend",
        "Reykjavik": "Lamb soup, fresh fish and famous hot dogs",
        "Bali": "Nasi goreng, satay and beachfront seafood",
        "Banff": "Poutine and hearty lodge fare after the trails",
        "Lisbon": "Pastéis de nata and fresh grilled sardines",
        "Rome": "Cacio e pepe, carbonara and gelato",
        "Cape Town": "Braai, biltong and world-class winelands"
    ]

    private static let shopping: [String: String] = [
        "Kyoto": "Where to find luxury boutiques and trendy fashion",
        "Shibuya": "Where to find luxury boutiques and trendy fashion",
        "Santorini": "Cliffside galleries and artisan jewelry",
        "Patagonia": "Outdoor gear and handwoven textiles",
        "Amalfi Coast": "Ceramics, sandals and limoncello shops",
        "Swiss Alps": "Watches, chocolate and alpine crafts",
        "Marrakech": "Haggle for treasures in the souks",
        "East Lansing": "Spartan gear and boutiques along Grand River Avenue",
        "Michigan State": "The Student Book Store and Spartan Spirit Shop",
        "Reykjavik": "Wool sweaters and design shops on Laugavegur",
        "Bali": "Craft markets and boutique surf wear in Seminyak",
        "Banff": "Outdoor outfitters and maple treats on Banff Avenue",
        "Lisbon": "Azulejo tiles and vintage finds in Feira da Ladra",
        "Rome": "Designer flagships near the Spanish Steps",
        "Cape Town": "African art and craft at the Watershed market"
    ]

    // MARK: - Activities content

    @ViewBuilder
    private var activitiesSection: some View {
        Text("Things to Do")
            .font(.title3.weight(.bold))
            .foregroundStyle(RoamiTheme.deepGreen)
            .padding(.top, 4)

        sectionCard(
            title: "Outdoor Activities",
            subtitle: Self.outdoorActivities[destination.name] ?? "Trails, water and open-air adventures",
            systemImage: "figure.hiking"
        )
        sectionCard(
            title: "Educational Activities",
            subtitle: Self.educationalActivities[destination.name] ?? "Museums, tours and hands-on workshops",
            systemImage: "book.fill"
        )
        sectionCard(
            title: "Cultural Activities",
            subtitle: Self.culturalActivities[destination.name] ?? "Festivals, traditions and local arts",
            systemImage: "theatermasks.fill"
        )
        sectionCard(
            title: "Night Life",
            subtitle: Self.nightLife[destination.name] ?? "Bars, live music and evening hot spots",
            systemImage: "moon.stars.fill"
        )
    }

    /// Sample per-destination activity lines; replace with real data
    /// when a backend exists.
    private static let outdoorActivities: [String: String] = [
        "Kyoto": "Hike the Fushimi Inari trails and cycle the Kamo River",
        "Shibuya": "Stroll Yoyogi Park and day-trip to Mount Takao",
        "Santorini": "Hike Fira to Oia and swim volcanic hot springs",
        "Patagonia": "Trek the W Circuit and kayak glacial lakes",
        "Amalfi Coast": "Walk the Path of the Gods and swim hidden coves",
        "Swiss Alps": "Ski world-class slopes and ride alpine cable cars",
        "Marrakech": "Camel rides and Atlas Mountains day treks",
        "East Lansing": "Kayak the Red Cedar and bike the Lansing River Trail",
        "Michigan State": "Stroll the Beal Botanical Garden and riverside paths"
    ]

    private static let educationalActivities: [String: String] = [
        "Kyoto": "Tea ceremony workshops and temple history tours",
        "Shibuya": "Meiji Shrine museum visits and teamLab exhibits",
        "Santorini": "Tour the Akrotiri ruins and local wineries",
        "Patagonia": "Glacier science tours and estancia visits",
        "Amalfi Coast": "Explore Pompeii and paper-making museums",
        "Swiss Alps": "Ride the Jungfraujoch railway and visit alpine dairies",
        "Marrakech": "Ben Youssef Madrasa tours and cooking classes",
        "East Lansing": "Abrams Planetarium shows and MSU Museum exhibits",
        "Michigan State": "Tour Beaumont Tower and the Broad Art Museum"
    ]

    private static let culturalActivities: [String: String] = [
        "Kyoto": "Geisha district evenings and seasonal festivals",
        "Shibuya": "Karaoke culture and street fashion scenes",
        "Santorini": "Village festivals and Cycladic art",
        "Patagonia": "Gaucho traditions and heritage estancias",
        "Amalfi Coast": "Cathedral visits and coastal festival nights",
        "Swiss Alps": "Alphorn festivals and mountain village traditions",
        "Marrakech": "Jemaa el-Fnaa storytellers and riad music nights",
        "East Lansing": "Broadway tours at the Wharton Center",
        "Michigan State": "Football Saturdays at Spartan Stadium — Go Green!"
    ]

    private static let nightLife: [String: String] = [
        "Kyoto": "Izakaya alleys in Pontocho and riverside bars",
        "Shibuya": "Neon-lit clubs, karaoke bars and rooftop lounges",
        "Santorini": "Sunset cocktails and cliffside wine bars",
        "Patagonia": "Cozy craft breweries and stargazing nights",
        "Amalfi Coast": "Seaside aperitivos and beach club evenings",
        "Swiss Alps": "Après-ski bars and mountain lodge fireside nights",
        "Marrakech": "Rooftop lounges and late-night medina cafés",
        "East Lansing": "College bars and live music on Albert Avenue",
        "Michigan State": "Tailgates and late-night eats on Grand River"
    ]

    // MARK: - Stays content

    @ViewBuilder
    private var staysSection: some View {
        Text("Where to Stay")
            .font(.title3.weight(.bold))
            .foregroundStyle(RoamiTheme.deepGreen)
            .padding(.top, 4)

        sectionCard(
            title: "Hotels",
            subtitle: Self.hotels[destination.name] ?? "Comfortable stays in great locations",
            systemImage: "building.2.fill"
        )
        sectionCard(
            title: "Hostels",
            subtitle: Self.hostels[destination.name] ?? "Budget-friendly beds and social common rooms",
            systemImage: "backpack.fill"
        )
        sectionCard(
            title: "Luxury",
            subtitle: Self.luxuryStays[destination.name] ?? "Five-star resorts and signature suites",
            systemImage: "crown.fill"
        )
        sectionCard(
            title: "Rentals",
            subtitle: Self.rentals[destination.name] ?? "Apartments, villas and home rentals",
            systemImage: "key.fill"
        )
    }

    /// Sample per-destination stay lines; replace with real data when a
    /// backend exists.
    private static let hotels: [String: String] = [
        "Kyoto": "Modern comfort near Kyoto Station and Gion",
        "Shibuya": "High-rise stays steps from Shibuya Crossing",
        "Santorini": "Cave hotels carved into the caldera cliffs",
        "Patagonia": "Lodges with mountain views in Puerto Natales",
        "Amalfi Coast": "Cliffside hotels overlooking the sea",
        "Swiss Alps": "Chalet hotels in Zermatt and Grindelwald",
        "Marrakech": "Traditional riads inside the medina walls",
        "East Lansing": "The Graduate and boutique stays downtown",
        "Michigan State": "Kellogg Hotel & Conference Center on campus"
    ]

    private static let hostels: [String: String] = [
        "Kyoto": "Budget guesthouses near Downtown Kawaramachi",
        "Shibuya": "Capsule hotels and social hostels in the center",
        "Santorini": "Backpacker stays in Fira with caldera views",
        "Patagonia": "Trekker hostels near the national park gates",
        "Amalfi Coast": "Budget stays in Salerno and Sorrento",
        "Swiss Alps": "Mountain hostels with bunk-and-breakfast deals",
        "Marrakech": "Colorful budget riads and rooftop dorms",
        "East Lansing": "Budget motels along the Grand River corridor",
        "Michigan State": "Dorm-style summer stays near campus"
    ]

    private static let luxuryStays: [String: String] = [
        "Kyoto": "Five-star ryokans with private onsen baths",
        "Shibuya": "Sky-high suites with Tokyo skyline views",
        "Santorini": "Infinity-pool villas above the Aegean",
        "Patagonia": "All-inclusive eco-lodges inside the park",
        "Amalfi Coast": "Grand cliff-top resorts in Positano and Ravello",
        "Swiss Alps": "Five-star spa resorts with Matterhorn views",
        "Marrakech": "Palace hotels with courtyard gardens",
        "East Lansing": "Suites with stadium views on game weekends",
        "Michigan State": "Premium suites steps from Spartan Stadium"
    ]

    private static let rentals: [String: String] = [
        "Kyoto": "Machiya townhouse rentals in historic lanes",
        "Shibuya": "Compact city apartments near the station",
        "Santorini": "Whitewashed cliff homes with private terraces",
        "Patagonia": "Cabins and ranch stays outside the park",
        "Amalfi Coast": "Villa rentals with lemon-grove terraces",
        "Swiss Alps": "Self-catered chalets for ski weeks",
        "Marrakech": "Private riads with courtyard pools",
        "East Lansing": "Game-day house rentals in the Bailey neighborhood",
        "Michigan State": "Apartments and game-weekend rentals near campus"
    ]

    // MARK: - Safety content

    private static let alertFilters = ["All", "Weather", "Protest", "Public Transportation"]

    /// Advisory level/color/score shown in the Risk Advisory card, derived
    /// from the destination's risk level (moderate when none is set).
    private var riskProfile: (name: String, color: Color, score: Double) {
        switch destination.riskLevel {
        case .low: return ("Low", .green, 2.4)
        case .high: return ("High", RoamiTheme.rust, 8.2)
        case .moderate, nil: return ("Moderate", .yellow, 4.6)
        }
    }

    /// Well-known areas referenced in the sample protest alert, so the
    /// placeholder content reads naturally for each destination.
    private static let safetyHotspots: [String: String] = [
        "Kyoto": "Gion and Shijo Dori",
        "Santorini": "Fira and Oia",
        "Patagonia": "the Torres del Paine trailheads",
        "Amalfi Coast": "Positano and Amalfi town",
        "Swiss Alps": "Zermatt village center",
        "Shibuya": "Shibuya and Shinjuku",
        "Marrakech": "Jemaa el-Fnaa and the medina",
        "East Lansing": "Grand River Avenue and the downtown bar district",
        "Michigan State": "Spartan Stadium and the Breslin Center on game days"
    ]

    /// Sample alerts matching the Hi-Fi, localized to this destination.
    /// Replace with a real safety feed later.
    private var safetyAlerts: [SafetyAlert] {
        let hotspots = Self.safetyHotspots[destination.name] ?? "the city center and main transit hubs"
        return [
            SafetyAlert(
                title: "Protest Activity",
                message: "Protests are planned in central \(destination.name) May 18-May 20. Avoid the area around \(hotspots).",
                systemImage: "megaphone.fill",
                tint: RoamiTheme.rust,
                category: "Protest",
                riskTag: "High Risk",
                headline: "Political Protest Central \(destination.name)",
                lastUpdated: "May 17, 2026 at 8:00 Am",
                whatsHappening: "Protests are planned in central \(destination.name) from May 18 to May 20. Large gatherings are expected around \(hotspots).",
                impacts: [
                    "Road closures and traffic delays",
                    "Crowded public transportation",
                    "Businesses may close early",
                    "Increased police presence"
                ]
            ),
            SafetyAlert(
                title: "Extreme Heat",
                message: "High temperatures expected May 18th- May 21st. Stay hydrated and limit outdoor activity",
                systemImage: "cloud.sun.fill",
                tint: .orange,
                category: "Weather",
                riskTag: "Moderate Risk",
                headline: "Extreme Heat Warning",
                lastUpdated: "May 17, 2026 at 8:00 Am",
                whatsHappening: "High temperatures are expected across \(destination.name) from May 18th to May 21st. Stay hydrated and limit outdoor activity during midday hours.",
                impacts: [
                    "Heat exhaustion risk during midday",
                    "Crowded indoor attractions",
                    "Possible transit slowdowns"
                ]
            ),
            SafetyAlert(
                title: "Safety & Security",
                message: "Normal safety conditions. May 17, 2026 at 6:10 Am",
                systemImage: "shield.fill",
                tint: .green,
                category: nil, // general status, shown under "All" only
                riskTag: "Low Risk",
                headline: "Normal Safety Conditions",
                lastUpdated: "May 17, 2026 at 6:10 Am",
                whatsHappening: "No unusual safety conditions are reported in \(destination.name). Standard travel precautions apply.",
                impacts: [
                    "Standard security presence",
                    "No travel restrictions in effect"
                ]
            )
        ]
    }

    private var filteredAlerts: [SafetyAlert] {
        guard selectedAlertFilter != "All" else { return safetyAlerts }
        return safetyAlerts.filter { $0.category == selectedAlertFilter }
    }

    @ViewBuilder
    private var safetySection: some View {
        RiskAdvisoryCard(levelName: riskProfile.name, levelColor: riskProfile.color, score: riskProfile.score)

        Text("Last Updated 2 hours ago")
            .font(.caption)
            .foregroundStyle(RoamiTheme.sageGreen)

        alertFilterChips

        if filteredAlerts.isEmpty {
            Text("No \(selectedAlertFilter.lowercased()) alerts right now.")
                .font(.footnote)
                .foregroundStyle(RoamiTheme.sageGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
        } else {
            ForEach(filteredAlerts) { alert in
                NavigationLink(value: alert) {
                    SafetyAlertRow(alert: alert)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var alertFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Self.alertFilters, id: \.self) { filter in
                    let isSelected = filter == selectedAlertFilter
                    Button(action: { selectedAlertFilter = filter }) {
                        Text(filter)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(isSelected ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isSelected ? RoamiTheme.sunOrange : .white, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(destination.country.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(RoamiTheme.deepGreen)
                    .kerning(1)
                Text(destination.name)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(RoamiTheme.deepGreen)
                Text(destination.blurb ?? "Discover \(destination.name), \(destination.country).")
                    .font(.subheadline)
                    .foregroundStyle(RoamiTheme.sageGreen)
                    .padding(.top, 2)
            }

            Spacer()

            ProfileAvatarLink()
        }
    }

    // MARK: - Topic chips

    private var topicChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Self.topics, id: \.self) { topic in
                    let isSelected = topic == selectedTopic
                    Button(action: { selectedTopic = topic }) {
                        Text(topic)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(isSelected ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isSelected ? RoamiTheme.sunOrange : .white, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Hero photo

    private var heroPhoto: some View {
        // Overlay-on-rectangle so the photo's intrinsic size can't
        // widen the layout (same pattern as DestinationCardView).
        Rectangle()
            .fill(RoamiTheme.sageGreen.opacity(0.25))
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .overlay {
                if let imageName = destination.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        // The fill overflows the frame; clipShape hides that
                        // visually but NOT for hit testing, so without this the
                        // invisible overflow steals taps from the topic chips.
                        .allowsHitTesting(false)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - Section cards

    private func sectionCard(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(RoamiTheme.rust)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(RoamiTheme.deepGreen)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(RoamiTheme.sageGreen)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

// MARK: - Safety alert row
// (The SafetyAlert model lives in SafetyAlertDetailView.swift, shared
// with the alert detail screen.)

private struct SafetyAlertRow: View {
    let alert: SafetyAlert

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: alert.systemImage)
                .font(.title2)
                .foregroundStyle(alert.tint)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 3) {
                Text(alert.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(RoamiTheme.deepGreen)
                Text(alert.message)
                    .font(.caption)
                    .foregroundStyle(RoamiTheme.sageGreen)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(RoamiTheme.sageGreen)
        }
        .padding(14)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

// MARK: - Risk advisory card + gauge

private struct RiskAdvisoryCard: View {
    let levelName: String
    let levelColor: Color
    let score: Double // 0...10

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Risk Advisory")
                    .font(.headline.weight(.bold))
                HStack(spacing: 6) {
                    Circle()
                        .fill(levelColor)
                        .frame(width: 12, height: 12)
                    Text(levelName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(levelColor)
                }
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Travel Risk")
                    .font(.caption.weight(.semibold))
                RiskGaugeView(score: score)
                Text("Score: \(score, specifier: "%.1f") /10")
                    .font(.system(size: 8))
                    .foregroundStyle(RoamiTheme.sageGreen)
            }
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

/// Semicircular green→red gauge with a needle pointing at `score` (0–10).
private struct RiskGaugeView: View {
    let score: Double

    private var fraction: Double { min(max(score / 10, 0), 1) }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Top half of a 90pt circle, swept left (Low) to right (High).
            // The outer 45pt-tall frame crops layout to just the arc; the
            // circle's empty bottom half overflows invisibly.
            Circle()
                .trim(from: 0.5, to: 1.0)
                .stroke(
                    AngularGradient(
                        colors: [.green, .yellow, .orange, .red],
                        center: .center,
                        startAngle: .degrees(180),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 9, lineCap: .round)
                )
                .frame(width: 90, height: 90)
                .frame(width: 90, height: 45, alignment: .top)

            // Needle pivoting on the arc's center point (bottom-center).
            Capsule()
                .fill(Color.black)
                .frame(width: 3, height: 30)
                .rotationEffect(.degrees(-90 + fraction * 180), anchor: .bottom)

            Circle()
                .fill(Color.black)
                .frame(width: 7, height: 7)
                .offset(y: 3)
        }
        .frame(width: 100, height: 45, alignment: .bottom)
        .overlay(alignment: .bottomLeading) {
            Text("Low").font(.system(size: 8)).foregroundStyle(RoamiTheme.sageGreen).offset(y: 10)
        }
        .overlay(alignment: .bottomTrailing) {
            Text("High").font(.system(size: 8)).foregroundStyle(RoamiTheme.sageGreen).offset(y: 10)
        }
        .padding(.bottom, 10)
    }
}

#Preview("Summary") {
    NavigationStack {
        DestinationDetailView(
            destination: Destination(
                name: "Kyoto",
                country: "Japan",
                imageName: "explore-kyoto",
                blurb: "A city where centuries of tradition meet quiet temple gardens."
            )
        )
    }
}

#Preview("Activities") {
    NavigationStack {
        DestinationDetailView(
            destination: Destination(
                name: "Kyoto",
                country: "Japan",
                imageName: "explore-kyoto",
                blurb: "A city where centuries of tradition meet quiet temple gardens."
            ),
            initialTopic: "Activities"
        )
    }
}

#Preview("Stays") {
    NavigationStack {
        DestinationDetailView(
            destination: Destination(
                name: "Kyoto",
                country: "Japan",
                imageName: "explore-kyoto",
                blurb: "A city where centuries of tradition meet quiet temple gardens."
            ),
            initialTopic: "Stays"
        )
    }
}

#Preview("Safety") {
    NavigationStack {
        DestinationDetailView(
            destination: Destination(
                name: "Kyoto",
                country: "Japan",
                imageName: "explore-kyoto",
                blurb: "A city where centuries of tradition meet quiet temple gardens."
            ),
            initialTopic: "Safety"
        )
    }
}
