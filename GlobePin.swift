//
//  GlobePin.swift
//  Roami
//
//  A labeled location on the 3D globe (e.g. "Kyoto", "Santorini").
//  Latitude/longitude drive its position on the sphere; SceneKit does
//  the projection into 3D, and GlobeSceneContainer projects that back
//  into 2D screen space each frame so we can overlay a real SwiftUI
//  label on top of the 3D view.
//

import Foundation

struct GlobePin: Identifiable, Hashable {
    let id: UUID
    let name: String
    let latitude: Double   // degrees, -90...90
    let longitude: Double  // degrees, -180...180

    init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension GlobePin {
    /// Placeholder pins matching the Hi-Fi. Swap for real trip/destination
    /// data once that's wired up (e.g. from ExploreViewModel or a trips API).
    static let sample: [GlobePin] = [
        GlobePin(name: "Reykjavik", latitude: 64.1466, longitude: -21.9426),
        GlobePin(name: "Santorini", latitude: 36.3932, longitude: 25.4615),
        GlobePin(name: "Kyoto", latitude: 35.0116, longitude: 135.7681),
        GlobePin(name: "Patagonia", latitude: -50.9423, longitude: -73.4068)
    ]
}
