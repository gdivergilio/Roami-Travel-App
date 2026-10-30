//
//  ExploreViewModel.swift
//  Roami
//
//  Owns the data shown on the Explore screen. Currently seeded with
//  placeholder data matching the Hi-Fi; swap `loadDestinations()` for
//  a real network/service call when the backend is ready — the view
//  itself won't need to change.
//

import Foundation
import Combine

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var trending: [Destination] = []
    @Published var exploreGrid: [Destination] = []
    @Published var isLoading: Bool = false

    /// Destinations found by the global (Wikipedia) lookup for the
    /// current search text — lets users search any country or city,
    /// not just the curated catalog.
    @Published var globalSearchResults: [Destination] = []

    /// Grid filtered by search text; falls back to full grid when empty.
    /// Searching matches destination name OR country across *all*
    /// destinations (trending included), so typing e.g. "Japan" surfaces
    /// both Kyoto and Shibuya — plus any global lookup results that
    /// aren't already covered by the catalog.
    var filteredExploreGrid: [Destination] {
        guard !searchText.isEmpty else { return exploreGrid }
        let local = (trending + exploreGrid).filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.country.localizedCaseInsensitiveContains(searchText)
        }
        let remote = globalSearchResults.filter { result in
            !local.contains { $0.name.caseInsensitiveCompare(result.name) == .orderedSame }
        }
        return local + remote
    }

    /// Looks the search text up on Wikipedia (free, no API key) and turns
    /// the page summary into a Destination: title, description, blurb,
    /// thumbnail photo and coordinates. Works for any country or city.
    func searchGlobalDestination() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.count >= 3 else {
            globalSearchResults = []
            return
        }

        let page = query.replacingOccurrences(of: " ", with: "_")
        guard let encoded = page.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(encoded)") else {
            globalSearchResults = []
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let summary = try JSONDecoder().decode(WikiSummary.self, from: data)

            // Places only — this is a travel search, not an encyclopedia.
            // Two gates: the article must be geotagged (objects like
            // "t-shirt" have no coordinates), and its description must
            // identify it as a country/city/region-type place.
            guard summary.type == "standard",
                  let description = summary.description,
                  summary.coordinates != nil,
                  Self.isPlace(description) else {
                globalSearchResults = []
                return
            }
            // Wikipedia's lead image is frequently a flag, coat of arms, or
            // locator map rather than an actual photo of the place — bad
            // ones get swapped for a real scenic photo from Unsplash.
            let photoURL: URL?
            if let thumbnail = summary.thumbnail?.source, Self.isScenicPhoto(thumbnail) {
                photoURL = thumbnail
            } else {
                photoURL = await Self.fetchUnsplashPhoto(query: summary.title)
            }

            // Bail if the text changed while we were fetching.
            guard searchText.trimmingCharacters(in: .whitespacesAndNewlines) == query else { return }

            globalSearchResults = [
                Destination(
                    name: summary.title,
                    country: description,
                    imageURL: photoURL,
                    blurb: summary.extract.map { String($0.prefix(while: { $0 != "." })) + "." },
                    riskLevel: .moderate, // default until a real safety feed exists
                    latitude: summary.coordinates?.lat,
                    longitude: summary.coordinates?.lon
                )
            ]
        } catch {
            globalSearchResults = []
        }
    }

    /// Rejects Wikipedia lead images that are flags, coats of arms, seals,
    /// emblems, or locator maps rather than photos of the place itself —
    /// these show up as the "thumbnail" for plenty of country/region
    /// articles. Filename keywords are a reliable signal since Wikimedia
    /// preserves the original file name in the thumbnail URL path.
    private static let unwantedImageKeywords = [
        "flag_of", "flag-of", "coat_of_arms", "coatofarms", "seal_of",
        "emblem_of", "locator_map", "location_map", "_map_of", "_map.",
        "logo", "insignia", "crest_of"
    ]

    private static func isScenicPhoto(_ url: URL) -> Bool {
        let path = url.absoluteString.lowercased()
        guard !path.hasSuffix(".svg") else { return false } // flags/maps are almost always vector art
        return !unwantedImageKeywords.contains { path.contains($0) }
    }

    /// Unsplash access key (unsplash.com/developers, free tier). Required
    /// for the fallback path — without one, destinations whose Wikipedia
    /// thumbnail was rejected simply show the app's placeholder instead.
    private static let unsplashAccessKey = ""

    /// Looks up a real, scenic photo of `query` on Unsplash. Used whenever
    /// Wikipedia's own lead image isn't an actual photo of the place.
    private static func fetchUnsplashPhoto(query: String) async -> URL? {
        guard !unsplashAccessKey.isEmpty,
              let encoded = "\(query) travel scenic".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.unsplash.com/search/photos?query=\(encoded)&per_page=1&orientation=landscape&content_filter=high") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(unsplashAccessKey)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let result = try JSONDecoder().decode(UnsplashSearchResponse.self, from: data)
            return result.results.first?.urls.regular
        } catch {
            return nil
        }
    }

    private struct UnsplashSearchResponse: Decodable {
        let results: [UnsplashPhoto]
    }

    private struct UnsplashPhoto: Decodable {
        struct URLs: Decodable { let regular: URL }
        let urls: URLs
    }

    /// Wikipedia's one-line description for geographic articles almost
    /// always names the kind of place ("Country in Western Europe",
    /// "City in Kansai, Japan", "State of the United States", ...).
    private static let placeKeywords = [
        "country", "city", "town", "village", "capital", "state",
        "province", "region", "island", "municipality", "prefecture",
        "territory", "district", "county", "commune", "settlement",
        "archipelago", "metropolis"
    ]

    private static func isPlace(_ description: String) -> Bool {
        let lowered = description.lowercased()
        return placeKeywords.contains { lowered.contains($0) }
    }

    private struct WikiSummary: Decodable {
        struct Thumbnail: Decodable { let source: URL }
        struct Coordinates: Decodable { let lat: Double; let lon: Double }

        let title: String
        let type: String?
        let description: String?
        let extract: String?
        let thumbnail: Thumbnail?
        let coordinates: Coordinates?
    }

    func loadDestinations() {
        isLoading = true
        // Placeholder data mirroring the Hi-Fi (see Destination.sample*).
        // Replace with a real async fetch later. Pin state lives in
        // FavoritesStore, not here.
        trending = Destination.sampleTrending
        exploreGrid = Destination.sampleExploreGrid
        isLoading = false
    }
}
