//
//  ProfileView.swift
//  Roami
//
//  The user's profile, pushed when the avatar in any screen's header is
//  tapped (via ProfileAvatarLink below). Per the Hi-Fi: centered name +
//  handle, large ringed profile photo with an edit affordance, home
//  country and member line, a mini "My Trips" list, and Account rows.
//
//  The profile photo is editable via the system photo picker; the chosen
//  image is persisted (App Storage) and shown by every header avatar.
//  Trip advisory notifications can be toggled on, which requests
//  notification permission and schedules advisory update alerts.
//

import SwiftUI
import PhotosUI
import UserNotifications

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navigation: AppNavigation

    private let trips: [(name: String, imageName: String)] = [
        ("Iceland", "trip-iceland"),
        ("Costa Rica", "trip-costa-rica")
    ]

    /// User-chosen profile photo, shared app-wide (empty = bundled default).
    @AppStorage("profile-photo-data") private var profilePhotoData = Data()
    @State private var photoPickerItem: PhotosPickerItem?

    // Editable profile info (see EditProfileView).
    @AppStorage("profile-name") private var name = "Jean-Paul"
    @AppStorage("profile-handle") private var handle = "jeanpaul"
    @AppStorage("profile-country") private var homeCountry = "Canada"
    @AppStorage("profile-tagline") private var tagline = "Solo Traveler & Content Creator"
    @State private var isEditingProfile = false

    /// Whether the user wants alerts when trip advisories change.
    @AppStorage("advisory-notifications-enabled") private var advisoryNotificationsEnabled = false

    private static let advisoryNotificationID = "trip-advisory-update"

    /// One height for every card row on this page (trips, account rows,
    /// the advisory toggle) so the layout reads as a tidy, even list.
    private static let rowHeight: CGFloat = 56

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text(name)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(RoamiTheme.deepGreen)
                Text("@\(handle)")
                    .font(.caption)
                    .foregroundStyle(RoamiTheme.sageGreen)

                // Photo + pencil are one photo-picker button: tapping either
                // opens the system photo library to choose a new picture.
                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                    VStack(spacing: 6) {
                        profilePhoto
                        Image(systemName: "pencil")
                            .font(.footnote)
                            .foregroundStyle(RoamiTheme.sageGreen)
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
                .onChange(of: photoPickerItem) {
                    Task {
                        if let data = try? await photoPickerItem?.loadTransferable(type: Data.self) {
                            profilePhotoData = data
                        }
                    }
                }

                Text("From \(homeCountry)")
                    .font(.subheadline)
                    .foregroundStyle(RoamiTheme.sageGreen)
                    .padding(.top, 12)

                Text("Member Since 2026 | \(tagline)")
                    .font(.footnote)
                    .foregroundStyle(RoamiTheme.sageGreen)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)

                myTripsSection
                    .padding(.top, 24)

                accountSection
                    .padding(.top, 24)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .background(RoamiTheme.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Explicit, always-visible way to leave the page (swipe-back
            // still works too).
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(RoamiTheme.deepGreen)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { isEditingProfile = true }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(RoamiTheme.deepGreen)
            }
        }
        .sheet(isPresented: $isEditingProfile) {
            EditProfileView()
        }
    }

    private var profilePhoto: some View {
        ProfilePhotoImage()
            .frame(width: 96, height: 96)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(.white, lineWidth: 4))
            .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
    }

    private var myTripsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My Trips")
                .font(.headline)
                .foregroundStyle(RoamiTheme.deepGreen)

            // Full-width rows with a fixed height so every card on the
            // page lines up with the Account rows below.
            ForEach(trips, id: \.name) { trip in
                HStack(spacing: 12) {
                    Image(trip.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .allowsHitTesting(false)

                    Text(trip.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(RoamiTheme.deepGreen)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(RoamiTheme.sageGreen)
                }
                .padding(.horizontal, 14)
                .frame(height: Self.rowHeight)
                .frame(maxWidth: .infinity)
                .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
            }

            Button(action: {
                dismiss()
                navigation.goToMyTrips()
            }) {
                Text("See more...")
                    .font(.caption)
                    .foregroundStyle(RoamiTheme.sageGreen)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Account

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account")
                .font(.headline)
                .foregroundStyle(RoamiTheme.deepGreen)

            accountRow(icon: "person.crop.circle", title: "Edit Profile") {
                isEditingProfile = true
            }
            accountNavigationRow(icon: "slider.horizontal.3", title: "Travel Preferences")
            accountNavigationRow(icon: "bell.fill", title: "Notifications")
            advisoryToggleRow
            accountNavigationRow(icon: "globe", title: "Language & Currency")
            accountNavigationRow(icon: "questionmark.circle.fill", title: "Help & Support")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Functional toggle: opt in/out of alerts when travel advisories
    /// change for an upcoming trip.
    private var advisoryToggleRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.fill")
                .font(.subheadline)
                .foregroundStyle(RoamiTheme.sunOrange)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text("Trip Advisory Updates")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(RoamiTheme.deepGreen)
                Text("Get notified when advisories change for your trips")
                    .font(.caption)
                    .foregroundStyle(RoamiTheme.sageGreen)
            }
            Spacer(minLength: 8)
            Toggle("Trip Advisory Updates", isOn: $advisoryNotificationsEnabled)
                .labelsHidden()
                .tint(RoamiTheme.sunOrange)
        }
        .padding(.horizontal, 14)
        .frame(height: Self.rowHeight)
        .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        .onChange(of: advisoryNotificationsEnabled) {
            advisoryNotificationsChanged()
        }
    }

    private func accountRow(
        icon: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            accountRowLabel(icon: icon, title: title)
        }
        .buttonStyle(.plain)
    }

    /// Rows without a real screen yet push a "Coming soon" placeholder
    /// instead of doing nothing.
    private func accountNavigationRow(icon: String, title: String) -> some View {
        NavigationLink {
            ComingSoonView(icon: icon, title: title)
        } label: {
            accountRowLabel(icon: icon, title: title)
        }
        .buttonStyle(.plain)
    }

    private func accountRowLabel(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(RoamiTheme.sunOrange)
                .frame(width: 26)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(RoamiTheme.deepGreen)
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(RoamiTheme.sageGreen)
        }
        .padding(.horizontal, 14)
        .frame(height: Self.rowHeight)
        .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    // MARK: - Advisory notifications

    private func advisoryNotificationsChanged() {
        let center = UNUserNotificationCenter.current()
        if advisoryNotificationsEnabled {
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async {
                    if granted {
                        scheduleAdvisoryNotification()
                    } else {
                        // Permission refused — reflect reality in the toggle.
                        advisoryNotificationsEnabled = false
                    }
                }
            }
        } else {
            center.removePendingNotificationRequests(withIdentifiers: [Self.advisoryNotificationID])
        }
    }

    /// Sample advisory alert for the upcoming trip, arriving shortly after
    /// opting in so the feature is demonstrable. A real implementation
    /// would push these from a safety feed instead.
    private func scheduleAdvisoryNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Travel Advisory Update"
        content.body = "New advisory for your upcoming Iceland trip: high winds expected along the South Coast June 16th–18th. Tap to review your itinerary."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.advisoryNotificationID,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Edit profile

/// Sheet for changing profile information. Fields bind straight to the
/// same App Storage values the profile page displays, so edits apply
/// immediately and persist across launches.
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("profile-name") private var name = "Jean-Paul"
    @AppStorage("profile-handle") private var handle = "jeanpaul"
    @AppStorage("profile-country") private var homeCountry = "Canada"
    @AppStorage("profile-tagline") private var tagline = "Solo Traveler & Content Creator"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    field("Name", text: $name)
                    field("Username", text: $handle)
                    field("Home Country", text: $homeCountry)
                    field("Travel Style", text: $tagline)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(RoamiTheme.background.ignoresSafeArea())
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(RoamiTheme.deepGreen)
                }
            }
        }
    }

    private func field(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(RoamiTheme.sageGreen)
            TextField(label, text: text)
                .font(.subheadline)
                .foregroundStyle(RoamiTheme.deepGreen)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

// MARK: - Profile photo image

/// The user's profile photo: the picked photo when one has been chosen,
/// otherwise the bundled placeholder. Used by both the profile page and
/// the header avatars so an edit shows up everywhere.
struct ProfilePhotoImage: View {
    @AppStorage("profile-photo-data") private var profilePhotoData = Data()

    var body: some View {
        Group {
            if let uiImage = UIImage(data: profilePhotoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image("profile-photo")
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}

// MARK: - Avatar link

/// The small circular avatar shown in every screen's header. Tapping it
/// pushes the profile, so the profile is reachable from any page. Must be
/// used inside a NavigationStack.
struct ProfileAvatarLink: View {
    var size: CGFloat = 36

    var body: some View {
        NavigationLink {
            ProfileView()
        } label: {
            ProfilePhotoImage()
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environmentObject(AppNavigation())
}
