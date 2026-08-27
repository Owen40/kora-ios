//
//  Cart.swift
//  Kora
//
//  Created by mac on 4/5/26.
//
import SwiftUI

struct CartView: View {
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var cart: CartManager
//    @State private var navigateToCheckout = false
    @State private var showClearCartAlert = false
    @State private var itemToRemove: CartItem?
    @State private var showRemoveAlert = false
    
    var onCheckout: () -> Void = {}
    
    var body: some View {
        Group {
            if cart.items.isEmpty {
                EmptyCartView(scheme: scheme)
            } else {
                ZStack(alignment: .bottom) {
                    VStack(spacing: 0) {
                        CartHeaderView(scheme: scheme, onClearCart: {
                            showClearCartAlert = true
                        })
                        
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 16) {
                                ForEach(cart.items) { item in
                                    CartItemRow(item: item, scheme: scheme, onRemove: {
                                        itemToRemove = item
                                        showRemoveAlert = true
                                    })
                                        .environmentObject(cart)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 120)
                        }
                    }
                    
                    Button(action: onCheckout) {
                        HStack {
                            Text("Checkout")
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
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .navigationTitle("Cart")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Clear Cart", isPresented: $showClearCartAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                withAnimation {
                    cart.clearCart()
                }
            }
        } message: {
            Text("Are you sure you want to remove all items from your cart?")
        }
        .alert("Remove Item", isPresented: $showRemoveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                withAnimation {
                    if let item = itemToRemove, let dishId = item.dish.id {
                        cart.removeFromCart(dishId: dishId)
                    }
                }
            }
        } message: {
            if let item = itemToRemove {
                Text("Remove \(item.dish.name) from your cart?")
            }
        }
    }
}

struct EmptyCartView: View {
    let scheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.button(for: scheme))
                    .frame(width: 120)
                Text("😔")
                    .font(.system(size: 48))
            }
            
            VStack(spacing: 12) {
                Text("Where's the food?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.text(for: scheme))
                
                Text("You can't eat air! Go add some delicious items to your cart")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.text(for: scheme).opacity(0.7))
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
            }
            Spacer()
        }
    }
}

struct CartHeaderView: View {
    let scheme: ColorScheme
    let onClearCart: () -> Void
    
    var body: some View {
        ZStack {
            Text("Cart")
                .font(.title2)
                .bold()
                .foregroundColor(Theme.text(for: scheme))
            
            HStack {
                Spacer()
                Button("Clear all") {
                    withAnimation {
                        onClearCart()
                    }
                }
                .font(.subheadline)
                .foregroundColor(Theme.placeholderText(for: scheme))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
}
