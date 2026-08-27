//
//  DashboardView.swift
//  Kora
//
//  Created by mac on 4/5/26.
//
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var cart: CartManager
    var onLogout: () -> Void
    
    var onCheckout: () -> Void = {}
    
    init(onLogout: @escaping () -> Void = {}, onCheckout: @escaping () -> Void = {}) {
        self.onLogout = onLogout
        self.onCheckout = onCheckout
        
        let appearance = UITabBarAppearance()
        let iconBarColor = UIColor(Theme.text(for: scheme))
        
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        appearance.stackedLayoutAppearance.normal.iconColor = iconBarColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            FavouritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favourites")
                }
                .tag(1)
            CartView(onCheckout: onCheckout)
                .environmentObject(cart)
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Cart")
                }
                .tag(2)
            ProfileView(onLogout: onLogout)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .tint(Theme.button(for: scheme))
    }
}

#Preview {
    MainTabView(onLogout: {})
}
