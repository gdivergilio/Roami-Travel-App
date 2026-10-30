//
//  IntroView.swift
//  Roami
//
//  The intro/splash screen per the Hi-Fi: the roami logo printed on an
//  unrolled parchment scroll (antique world map texture) with wooden
//  rods top and bottom and a hanging pull, on the app's cream background.
//
//  Interaction: drag down to unroll the scroll — the parchment follows
//  your finger. Release past halfway and the unroll completes and the
//  app cross-fades in (to the Home tab's globe); release earlier and it
//  springs back.
//

import SwiftUI

/// Root view for the app: intro scroll first, then the tabs.
struct AppLaunchView: View {
    @State private var showIntro = false // TEMP: skipped for simulator smoke test, reverting after

    var body: some View {
        ZStack {
            RootTabView()

            if showIntro {
                IntroView {
                    withAnimation(.easeOut(duration: 0.6)) {
                        showIntro = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

struct IntroView: View {
    /// Called when the user has fully unrolled the scroll.
    var onFinished: () -> Void = {}

    private let parchmentBase = Color(red: 0.82, green: 0.70, blue: 0.48)
    private let rodBrown = Color(red: 0.35, green: 0.24, blue: 0.13)

    @State private var unroll: CGFloat = 0 // extra parchment height revealed by the drag
    @State private var isFinishing = false

    var body: some View {
        GeometryReader { geo in
            let baseHeight = min(430, geo.size.height * 0.55)
            let maxUnroll = max(100, geo.size.height - baseHeight - 120)

            ZStack {
                RoamiTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    scrollRod

                    parchment
                        .frame(height: baseHeight + unroll)

                    scrollRod

                    hangingPull

                    if !isFinishing {
                        Text("Pull down to begin")
                            .font(.footnote)
                            .foregroundStyle(RoamiTheme.sageGreen)
                            .padding(.top, 14)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.top, 24)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard !isFinishing else { return }
                        unroll = min(max(0, value.translation.height), maxUnroll)
                    }
                    .onEnded { value in
                        guard !isFinishing else { return }
                        if unroll > maxUnroll * 0.5 {
                            isFinishing = true
                            withAnimation(.easeIn(duration: 0.35)) {
                                unroll = maxUnroll
                            }
                            Task {
                                try? await Task.sleep(for: .seconds(0.4))
                                onFinished()
                            }
                        } else {
                            withAnimation(.spring(duration: 0.4)) {
                                unroll = 0
                            }
                        }
                    }
            )
        }
    }

    /// The unrolled parchment: antique map texture, warmed toward
    /// parchment, with the logo multiply-blended so it reads as printed
    /// on the paper rather than pasted over it.
    private var parchment: some View {
        Rectangle()
            .fill(parchmentBase)
            .overlay {
                // Kept faint so it reads as aged parchment texture and the
                // logo stays dominant, like the Hi-Fi.
                Image("antique-map")
                    .resizable()
                    .scaledToFill()
                    .saturation(0.3)
                    .opacity(0.45)
                    .allowsHitTesting(false)
            }
            .overlay(parchmentBase.opacity(0.5).blendMode(.multiply))
            .overlay {
                Image("roami-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 230)
                    .blendMode(.multiply)
                    .opacity(0.9)
            }
            .clipped()
            .padding(.horizontal, 6) // parchment sits just inside the rods
    }

    /// Wooden scroll rod with rounded ends peeking past the parchment.
    private var scrollRod: some View {
        ZStack {
            Capsule()
                .fill(rodBrown)
                .frame(height: 16)
            HStack {
                Circle().fill(rodBrown.opacity(0.8)).frame(width: 20, height: 20)
                Spacer()
                Circle().fill(rodBrown.opacity(0.8)).frame(width: 20, height: 20)
            }
        }
        .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
    }

    /// The little cord + pendant hanging under the bottom rod.
    private var hangingPull: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(rodBrown.opacity(0.7))
                .frame(width: 1.5, height: 26)
            Circle()
                .fill(rodBrown)
                .frame(width: 7, height: 7)
            Capsule()
                .fill(rodBrown)
                .frame(width: 5, height: 16)
        }
    }
}

#Preview("Intro") {
    IntroView()
}

#Preview("Launch flow") {
    AppLaunchView()
}
