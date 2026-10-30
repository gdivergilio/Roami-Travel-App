//
//  DestinationCardView.swift
//  Roami
//
//  One card component with two visual styles so "Trending Destinations"
//  (compact, uniform width) and "Explore the World" (larger, shows the
//  pin + risk badge) don't need two separate implementations.
//
//  Per the Hi-Fi, every card is a white rounded container: the photo
//  sits flush at the top and the text lives on a white strip below it,
//  visually separated from the image by the background color change.
//

import SwiftUI

struct DestinationCardView: View {
    enum Style {
        case compact   // used in the horizontal Trending carousel
        case grid      // used in the Explore the World masonry grid
    }

    let destination: Destination
    let style: Style
    /// Grid cards come in two heights to create the Hi-Fi's staggered
    /// masonry look; ignored for compact cards.
    var isTall: Bool = false
    /// Whether this destination is currently favorited (FavoritesStore
    /// is the source of truth, not destination.isPinned).
    var isPinned: Bool = false
    var onTogglePin: (() -> Void)? = nil

    private var imageHeight: CGFloat {
        switch style {
        case .compact: return 90
        case .grid: return isTall ? 190 : 110
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            photo

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(destination.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(RoamiTheme.deepGreen)
                        .lineLimit(1)

                    if onTogglePin != nil {
                        Spacer(minLength: 0)
                        Button(action: { onTogglePin?() }) {
                            Image(systemName: isPinned ? "mappin.circle.fill" : "mappin")
                                .font(.subheadline)
                                .foregroundStyle(isPinned ? RoamiTheme.rust : .secondary)
                        }
                    }
                }

                if style == .compact {
                    Text(destination.country)
                        .font(.caption)
                        .foregroundStyle(RoamiTheme.sageGreen)
                }

                if let riskLevel = destination.riskLevel {
                    RiskBadgeView(level: riskLevel)
                }
            }
            .padding(10)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        .frame(width: style == .compact ? 130 : nil, alignment: .leading)
    }

    /// Bundled asset image when available, falling back to AsyncImage
    /// (and a sage placeholder) for remote/missing images.
    ///
    /// The image is applied as an overlay on a fixed-size rectangle so its
    /// intrinsic size can never widen the card/grid layout; `.clipped()`
    /// then trims the overflowing fill.
    private var photo: some View {
        Rectangle()
            .fill(RoamiTheme.sageGreen.opacity(0.25))
            .frame(height: imageHeight)
            .frame(maxWidth: .infinity)
            .overlay {
                Group {
                    if let imageName = destination.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    } else {
                        AsyncImage(url: destination.imageURL) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.clear
                        }
                    }
                }
                // The fill overflows the frame; .clipped() hides that visually
                // but NOT for hit testing, so without this the invisible
                // overflow steals taps from neighboring cards/buttons.
                .allowsHitTesting(false)
            }
            .clipped()
    }
}

#Preview {
    HStack(alignment: .top, spacing: 12) {
        DestinationCardView(
            destination: Destination(name: "Santorini", country: "Greece", imageName: "explore-santorini"),
            style: .compact
        )
        DestinationCardView(
            destination: Destination(name: "Amalfi Coast", country: "Italy", imageName: "explore-amalfi", riskLevel: .low),
            style: .grid,
            isTall: true,
            isPinned: true
        )
    }
    .padding()
    .background(RoamiTheme.background)
}
