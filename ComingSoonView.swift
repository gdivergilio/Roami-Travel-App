//
//  ComingSoonView.swift
//  Roami
//
//  Placeholder destination for Profile's Account rows that don't have a
//  real screen yet (Travel Preferences, Notifications, Language &
//  Currency, Help & Support) — stands in until each gets built out.
//

import SwiftUI

struct ComingSoonView: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(RoamiTheme.sunOrange)

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(RoamiTheme.deepGreen)

            Text("Coming soon")
                .font(.subheadline)
                .foregroundStyle(RoamiTheme.sageGreen)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
        .background(RoamiTheme.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ComingSoonView(icon: "bell.fill", title: "Notifications")
    }
}
