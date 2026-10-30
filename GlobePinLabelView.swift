//
//  GlobePinLabelView.swift
//  Roami
//
//  The dark maroon capsule label (e.g. "Kyoto") shown next to a pin.
//  Positioned by HomeView using the screen coordinates GlobeSceneContainer
//  reports each frame — this view itself has no knowledge of 3D space.
//

import SwiftUI

struct GlobePinLabelView: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(RoamiTheme.rust, in: Capsule())
    }
}

#Preview {
    GlobePinLabelView(name: "Kyoto")
        .padding()
        .background(.gray)
}
