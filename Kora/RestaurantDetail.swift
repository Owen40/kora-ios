//
//  RestaurantDetail.swift
//  Kora
//
//  Created by mac on 4/6/26.
//
import SwiftUI

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @Environment(\.colorScheme) var scheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var dishViewModel = DishViewModel()
    @EnvironmentObject var cart: CartManager
    
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    
    // Group dishes by category
    var groupedDishes: [String: [Dish]] {
        Dictionary(grouping: dishViewModel.dishes) { $0.category }
    }
    
    var sortedCategories: [String] {
        groupedDishes.keys.sorted()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if !restaurant.isRestaurantOpen() {
                // MARK: - Restaurant Closed View
                VStack(spacing: 20) {
                    Image(systemName: "clock.badge.xmark.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    Text("Restaurant is Closed")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Opens at \(restaurant.openingTime)")
                        .font(.headline)
                    Button("Go Back") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.background(for: scheme))
            } else {
                // MARK: - Restaurant Open View
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Restaurant Header
                        RestaurantHeaderView(restaurant: restaurant, scheme: scheme)
                        
                        // Loading State
                        if dishViewModel.uiState == .loading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        // Empty State
                        else if dishViewModel.dishes.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 50))
                                    .foregroundColor(Theme.text(for: scheme).opacity(0.5))
                                Text("No menu items available")
                                    .foregroundColor(Theme.text(for: scheme).opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 50)
                        }
                        // Dishes List
                        else {
                            ForEach(sortedCategories, id: \.self) { category in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(category)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Theme.text(for: scheme))
                                        .padding(.horizontal, 24)
                                        .padding(.top, 10)
                                    
                                    VStack(spacing: 16) {
                                        ForEach(groupedDishes[category] ?? []) { dish in
                                            MenuItemCard(dish: dish, scheme: scheme) {
                                                // Add to cart action
                                                cart.addToCart(dish: dish)
//                                                withAnimation(.spring()) {
//                                                    if let price = Double(dish.price) {
//                                                        cartTotal += price
//                                                        cartItemCount += 1
                                                        snackbarMessage = "Added \(dish.name) to cart"
                                                        showSnackbar = true
//                                                    }
//                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                        }
                        
                        // Extra padding so list isn't hidden behind the floating button
                        Spacer().frame(height: 100)
                    }
                }
            }
            
            // MARK: - Floating Checkout Button (Appears only if cart has items)
            if cart.itemCount > 0 {
                NavigationLink(destination: CartView().environmentObject(cart)) {
                    HStack {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text("View Cart (\(cart.itemCount) items)")
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                        Text(String(format: "KES %.2f", cart.total))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(Theme.background(for: scheme))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
                    .background(Theme.button(for: scheme))
                    .cornerRadius(16)
                    .shadow(color: Theme.button(for: scheme).opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .navigationTitle(restaurant.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Add to favourites action
                }) {
                    Image(systemName: "heart")
                        .foregroundColor(Theme.text(for: scheme))
                }
            }
        }
        .onAppear {
            // MARK: - Fetch dishes when view appears
            if let restaurantId = restaurant.id {
                print("🟢 Fetching dishes for restaurant ID: \(restaurantId)")
                dishViewModel.fetchDishes(restaurantId: restaurantId)
            } else {
                print("🔴 Restaurant ID is nil")
            }
        }
        .snackbar(isPresented: $showSnackbar, message: snackbarMessage, duration: 1.5)
    }
}
