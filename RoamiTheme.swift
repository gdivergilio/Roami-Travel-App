//
//  RoamiTheme.swift
//  Roami
//
//  Centralized design tokens. Every screen we build should pull colors
//  and type from here rather than hardcoding hex values, so the whole
//  app stays visually consistent as we go screen by screen.
//

import SwiftUI

enum RoamiTheme {
    // Backgrounds
    /// #F2F0E9 — every screen's background.
    static let background = Color(red: 242 / 255, green: 240 / 255, blue: 233 / 255)

    // Brand palette (exact hex codes from the original design)
    /// #455742 — headers, tab bar, city/country titles.
    static let deepGreen = Color(red: 69 / 255, green: 87 / 255, blue: 66 / 255)
    /// #94A185 — subheadings and body text.
    static let sageGreen = Color(red: 148 / 255, green: 161 / 255, blue: 133 / 255)
    /// #E47940 — selected/active buttons (e.g. topic and filter chips).
    static let sunOrange = Color(red: 228 / 255, green: 121 / 255, blue: 64 / 255)

    // Scroll/parchment accents
    static let bronze = Color(red: 0.42, green: 0.30, blue: 0.16)
    static let rust = Color(red: 0.58, green: 0.20, blue: 0.16) // matches map pin / risk-tag red

    // Type
    static let wordmarkFont: Font = .custom("Poppins-Bold", size: 34, relativeTo: .largeTitle)
    // ^ Swap "Poppins-Bold" for whatever the Hi-Fi's rounded-serif-adjacent
    //   logotype actually is once you export/identify the font file. Falls
    //   back to system bold automatically if the named font isn't bundled.
}
