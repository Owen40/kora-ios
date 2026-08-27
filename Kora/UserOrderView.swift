//
//  UserOrderView.swift
//  Kora
//
//  Created by mac on 4/10/26.
//
import SwiftUI

struct UserOrdersView: View {
    @Environment(\.colorScheme) var scheme
    @StateObject private var userOrderviewModel = UserOrdersViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if userOrderviewModel.isLoading {
                ProgressView()
                    .tint(Theme.button(for: scheme))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if userOrderviewModel.uiState.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bag")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.text(for: scheme))
                    Text("No Orders yet")
                        .foregroundColor(Theme.text(for: scheme))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(userOrderviewModel.uiState) { state in
                            NavigationLink(destination: OrderDetailsView(state: state)) {
                                OrderCardView(state: state, scheme: scheme)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .navigationTitle("Your Orders")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { /* Filter action */ }) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.text(for: scheme))
                        .frame(width: 36, height: 36)
                        .background(Theme.card(for: scheme))
                        .clipShape(Circle())
                }
            }
        }
    }
}

struct OrderCardView: View {
    let state: UserOrderUiState
    let scheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        // Status Badge
                        Text(state.statusText)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(state.isCancelled ? .red : .green)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(state.isCancelled ? Color.red.opacity(0.15) : Color.green.opacity(0.15))
                            .cornerRadius(12)
                        
                        Text(state.order.id ?? "00000")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.placeholderText(for: scheme))
                    }
                    
                    Text(state.restaurantName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Theme.text(for: scheme))
                        .padding(.top, 4)
                    
                    Text(state.formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.placeholderText(for: scheme))
                    
                    HStack(spacing: 4) {
                        Text("Total:")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.placeholderText(for: scheme))
                        Text(String(format: "KES %.2f", state.order.total ?? 0.0))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.text(for: scheme))
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
                
                // Restaurant / Food Image
                AsyncImage(url: URL(string: state.imageUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(Theme.placeholderText(for: scheme).opacity(0.2))
                    }
                }
                .frame(width: 80, height: 80)
                .cornerRadius(12)
                .clipped()
            }
            .padding(16)
            
            Divider()
                .background(Theme.placeholderText(for: scheme).opacity(0.2))
                .padding(.horizontal, 16)
            
            HStack {
                Text(state.itemDescription)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.placeholderText(for: scheme))
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: { /* Implement reorder logic */ }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12, weight: .bold))
                        Text("Reorder")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.button(for: scheme))
                    .cornerRadius(8)
                }
            }
            .padding(16)
        }
        .background(Theme.card(for: scheme))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
}
