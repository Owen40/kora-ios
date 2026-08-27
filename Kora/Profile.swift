//
//  Profile.swift
//  Kora
//
//  Created by mac on 4/5/26.
//
import SwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) var scheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isFaceIDEnabled") private var isFaceIDEnabled = false

    @StateObject private var authViewModel = AuthViewModel()
    @State private var showLogoutConfirmation = false
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""

    @Environment(\.dismiss) var dismiss
    var onLogout: () -> Void = {}

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                Spacer().frame(height: 30)

                ZStack {
                    Circle()
                        .fill(Theme.text(for: scheme))
                        .frame(width: 120)

                    Text(getUserInitials())
                        .foregroundColor(Theme.background(for: scheme))
                        .font(.system(size: 40, weight: .bold))
                }

                VStack(spacing: 5) {
                    Text(getUserFullName())
                        .bold()
                        .font(.title2)
                        .foregroundColor(Theme.text(for: scheme))

                    Text(authViewModel.currentUser?.email ?? "user@example.com")
                        .font(.subheadline)
                        .foregroundColor(Theme.text(for: scheme))

                    if let role = authViewModel.currentUser?.role {
                        Text(role.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Theme.button(for: scheme).opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(Theme.button(for: scheme))
                            .padding(.top, 4)
                    }
                }

                Button(action: {}) {
                    Text("Edit profile")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.background(for: scheme))
                        .frame(width: 220)
                        .padding(.vertical, 16)
                        .background(Theme.button(for: scheme))
                        .cornerRadius(30)
                }
                .padding(.bottom, 20)

                VStack(spacing: 20) {
                    NavigationLink(destination: UserOrdersView()) {
                        ProfileRow(
                            icon: "cart.fill",
                            title: "Orders",
                            subtitle: "Track and Manage your deliveries",
                            scheme: scheme
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    NavigationLink(destination: AddressesView()) {
                        ProfileRow(
                            icon: "mappin.circle",
                            title: "Address",
                            subtitle: "Manage your delivery addresses",
                            scheme: scheme
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // MARK: - New Allergens Screen Navigation
                    NavigationLink(
                        destination: AllergenSelectionView(onComplete: {
                            // Dismiss back to profile when done
                        })
                    ) {
                        ProfileRow(
                            icon: "leaf.fill",
                            title: "Allergens",
                            subtitle: "Manage your dietary restrictions",
                            scheme: scheme
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    ProfileRow(
                        icon: "bell.fill",
                        title: "Notifications",
                        subtitle: "Customize your Alerts",
                        scheme: scheme
                    )
                    ProfileRow(
                        icon: "headphones",
                        title: "Help and Support",
                        subtitle: "Get assistance and find answers",
                        scheme: scheme
                    )
                    ProfileRow(
                        icon: "star.fill",
                        title: "Terms and Policies",
                        subtitle: "read our terms and guidelines",
                        scheme: scheme
                    )

                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            Image(
                                systemName: isDarkMode
                                    ? "moon.fill" : "sun.max.fill"
                            )
                            .font(.system(size: 24))
                            .foregroundColor(Theme.text(for: scheme))
                            .frame(width: 30)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Dark Mode")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(
                                        Theme.text(for: scheme).opacity(0.6)
                                    )
                                Text("Switch between light and Dark themes")
                                    .font(.system(size: 12))
                                    .foregroundColor(
                                        Theme.text(for: scheme).opacity(0.6)
                                    )
                            }
                            Spacer()
                            Toggle("", isOn: $isDarkMode)
                                .labelsHidden()
                                .tint(Theme.button(for: scheme))
                        }

                        Divider().background(
                            Theme.text(for: scheme).opacity(0.1)
                        )

                        HStack(spacing: 20) {
                            Image(systemName: "faceid")
                                .font(.system(size: 24))
                                .foregroundColor(Theme.text(for: scheme))
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Face ID Unlock")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(
                                        Theme.text(for: scheme).opacity(0.8)
                                    )
                                Text("Require Face ID to open the app")
                                    .font(.system(size: 12))
                                    .foregroundColor(
                                        Theme.text(for: scheme).opacity(0.6)
                                    )
                            }
                            Spacer()
                            Toggle("", isOn: $isFaceIDEnabled)
                                .labelsHidden()
                                .tint(Theme.button(for: scheme))
                        }
                    }
                    //                    .padding()
                    //                    .background(.ultraThinMaterial)
                    //                    .cornerRadius(20)
                }

                Button(action: {
                    showLogoutConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Logout")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 300)
                    .padding(.vertical, 16)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(30)
                }
                .padding(.top, 30)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .onAppear {
            authViewModel.fetchCurrentUser()
        }
        .onReceive(authViewModel.$authState) { state in
            switch state {
            case .error(let message):
                snackbarMessage = message
                showSnackbar = true
                authViewModel.resetState()
            default:
                break
            }
        }
        .alert("Logout", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                performLogout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .snackbar(isPresented: $showSnackbar, message: snackbarMessage)
    }
    private func getUserFullName() -> String {
        guard let user = authViewModel.currentUser else {
            return "Not Found"
        }
        return "\(user.firstName) \(user.lastName)"
    }
    private func getUserInitials() -> String {
        guard let user = authViewModel.currentUser else {
            return "NF"
        }
        let firstNameInitial = user.firstName.prefix(1)
        let lastNameInitial = user.lastName.prefix(1)
        return "\(firstNameInitial)\(lastNameInitial)".uppercased()
    }

    private func performLogout() {
        authViewModel.logout()
        onLogout()
    }
}

#Preview {
    ProfileView(
        onLogout: {}
    )
}
