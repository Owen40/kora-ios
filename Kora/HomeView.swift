//
//  HomeView.swift
//  Kora
//
//  Created by mac on 4/5/26.
//
import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var scheme
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var restaurantViewModel = RestaurantViewModel()
    @State private var searchText = ""
    
    var filteredRestaurants: [Restaurant] {
        if searchText.isEmpty {
            return restaurantViewModel.restaurants
        } else {
            return restaurantViewModel.restaurants.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                ($0.cuisine ??  "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                headerSection
                
                // Search Bar
                searchBar
                
                // Restaurants Section
                restaurantsSection
                
                Spacer().frame(height: 100)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .refreshable {
            restaurantViewModel.fetchRestaurants()
            authViewModel.fetchCurrentUser()
        }
        .onAppear {
            authViewModel.fetchCurrentUser()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome Back,")
                    .font(.title3)
                    .foregroundColor(Theme.text(for: scheme).opacity(0.8))
                Text(getUserDisplayName())
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Theme.text(for: scheme))
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.text(for: scheme))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Theme.placeholderText(for: scheme))
                .font(.system(size: 18))
            
            TextField("", text: $searchText, prompt: Text("Find a restaurant").foregroundColor(Theme.placeholderText(for: scheme)))
                .foregroundColor(Theme.text(for: scheme))
            
            Image(systemName: "mic")
                .foregroundColor(Theme.placeholderText(for: scheme))
                .font(.system(size: 18))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(
            ZStack {
                Theme.card(for: scheme).opacity(0.7)
                Rectangle().fill(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 30))
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Restaurants Section
    private var restaurantsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Restaurants")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Theme.text(for: scheme))
                .padding(.horizontal, 24)
                .padding(.top, 10)
            
            // Loading State
            if restaurantViewModel.uiState == .loading && restaurantViewModel.restaurants.isEmpty {
                ForEach(0..<3, id: \.self) { _ in
                    SkeletonRestaurantCard(scheme: scheme)
                        .padding(.bottom, 8)
                }
            }
            // Empty State
            else if filteredRestaurants.isEmpty {
                emptyStateView
            }
            // Restaurants List
            else {
                restaurantsList
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife")
                .font(.system(size: 50))
                .foregroundColor(Theme.text(for: scheme).opacity(0.5))
            Text(searchText.isEmpty ? "No restaurants available" : "No Restaurants found")
                .foregroundColor(Theme.text(for: scheme).opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
    
    // MARK: - Restaurants List
    private var restaurantsList: some View {
        ForEach(filteredRestaurants) { restaurant in
            NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                RestaurantCardView(restaurant: restaurant)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Restaurant Card View (Extracted for clarity)
    private func RestaurantCardView(restaurant: Restaurant) -> some View {
        RestaurantCard(
            restaurant: restaurant,
            scheme: scheme,
            isFavourite: restaurantViewModel.favouriteIds.contains(restaurant.id ?? "")
        ) {
            if let id = restaurant.id {
                restaurantViewModel.toggleFavourite(restaurantId: id)
            }
        }
        .overlay(
            closedOverlay
                .opacity(restaurant.isRestaurantOpen() ? 0 : 1)
        )
    }
    
    // MARK: - Closed Overlay
    private var closedOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .cornerRadius(16)
            
            VStack(spacing: 8) {
                Image(systemName: "clock.badge.xmark.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                Text("Closed")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                // Note: You'll need to pass the opening time here
                // This is a placeholder - you'll need to modify this
                Text("Check back later")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
//            .padding()
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Helper Methods
    private func getUserDisplayName() -> String {
        if let user = authViewModel.currentUser {
            return "\(user.firstName) \(user.lastName)"
        }
        return "Guest User"
    }
}

struct SkeletonRestaurantCard: View {
    let scheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Placeholder
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 180)
            
            // Text Placeholders
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 180, height: 20)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 14)
            }
            .padding()
        }
        .background(Theme.card(for: scheme))
        .cornerRadius(16)
        .padding(.horizontal, 24)
        .shimmering()
    }
}

//#Preview {
//    HomeView()
//}
