//
//  RiskBadgeView.swift
//  Roami
//
//  Small "⚠ Low risk" style badge shown under destination cards.
//  Reused later on the Country/Safety detail screens, so it lives
//  as its own component rather than being inlined into the card.
//

import SwiftUI

struct RiskBadgeView: View {
    let level: RiskLevel

    var body: some View {
        Label(level.rawValue, systemImage: level.systemImage)
            .font(.caption2.weight(.medium))
            .foregroundStyle(tintColor)
    }

    private var tintColor: Color {
        switch level {
        case .low: return .green
        case .moderate: return .orange
        case .high: return RoamiTheme.rust
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        RiskBadgeView(level: .low)
        RiskBadgeView(level: .moderate)
        RiskBadgeView(level: .high)
    }
    .padding()
}
