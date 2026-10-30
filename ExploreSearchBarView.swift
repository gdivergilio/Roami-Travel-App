//
//  ExploreSearchBarView.swift
//  Roami
//
//  The pill-shaped search field + user avatar row at the top of Explore.
//

import SwiftUI

struct ExploreSearchBarView: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(RoamiTheme.sageGreen)

                TextField("Search destinations...", text: $text)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())

            ProfileAvatarLink()
        }
    }
}

private struct ExploreSearchBarPreview: View {
    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ExploreSearchBarView(text: $text, isFocused: $isFocused)
                .padding()
        }
    }
}

#Preview {
    ExploreSearchBarPreview()
}
