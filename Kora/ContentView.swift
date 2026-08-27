//
//  ContentView.swift
//  Kora
//
//  Created by mac on 4/4/26.
//

import SwiftUI
import LocalAuthentication


enum AppRoute: Hashable {
    case onboarding2
    case signIn
    case signUp
    case allergenSelection
    case dashboard
    case checkout
    case orderSuccess(orderNumber: String, estimatedTime: String)
}

struct ContentView: View {
    @State private var path = NavigationPath()
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isFaceIDEnabled") private var isFaceIDEnabled = false
    
    @StateObject private var cart = CartManager()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var locationManager = LocationManager()
    
    @State private var isAuthenticated = false
    @State private var isUnlocked = false
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if isAuthenticated {
                    if isFaceIDEnabled && !isUnlocked {
                        VStack(spacing: 24) {
                            Image(systemName: "faceid")
                                .font(.system(size: 80))
                                .foregroundColor(.primary)
                            Text("App locked")
                                .font(.title2.bold())
                            
                            Button(action: authenticateUser) {
                                Text("Unlock with Face ID")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 32)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(30)
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Theme.background(for: isDarkMode ? .dark : .light).ignoresSafeArea())
                    } else {
                        MainTabView(
                            onLogout: { handleLogout() },
                            onCheckout: { path.append(AppRoute.checkout) }
                        )
                        .navigationBarBackButtonHidden(true)
                    }
                } else {
                    Onboarding1View {
                        path.append(AppRoute.onboarding2)
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .onboarding2:
                    Onboarding2View {
                        path.append(AppRoute.signIn)
                    }
                case .signIn:
                    SignInView(
                        onSignUp: {
                            path.append(AppRoute.signUp)
                        },
                        onSignIn: {
                            path.append(AppRoute.dashboard)
                        }
                    )
//                    .environmentObject(authViewModel)
                case .signUp:
                    SignUpView(
                        onSignIn: {
                            path.removeLast()
                        },
                        onSignUp: {
                            path.append(AppRoute.allergenSelection)
                        }
                    )
                case .allergenSelection:
                    AllergenSelectionView(onComplete: {
                        path.append(AppRoute.dashboard)
                    })
                    .navigationBarBackButtonHidden(true)
                case .dashboard:
                    MainTabView(
                        onLogout: { path.append(AppRoute.signIn) },
                        onCheckout: { path.append(AppRoute.checkout) }
                    )
                        .navigationBarBackButtonHidden(true)
                case .checkout:
                    CheckoutView(onOrderSuccess: { orderNumber, estimatedTime in
                        path.append(AppRoute.orderSuccess(orderNumber: orderNumber, estimatedTime: estimatedTime))
                    })
                    .environmentObject(cart)
                case .orderSuccess(let orderNumber, let estimatedTime):
                    OrderSuccessView(
                        orderNumber: orderNumber,
                        estimatedTime: estimatedTime,
                        onGoHome: {
                            cart.clearCart()
                            path = NavigationPath()
                            path.append(AppRoute.dashboard)
                    })
                    .navigationBarBackButtonHidden(true)
                }
                
            }
        }
        .onAppear {
            checkAuthenticationStatus()
            locationManager.requestLocation()
        }
//        .preferredColorScheme(.dark)
        .environmentObject(cart)
        .environmentObject(authViewModel)
    }
    private func checkAuthenticationStatus() {
            isAuthenticated = authViewModel.isUserLoggedIn
            
            if isAuthenticated {
                if isFaceIDEnabled {
                    authenticateUser()
                } else {
                    isUnlocked = true
                }
            }
    }
    
    private func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock to access your dashboard."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        self.isUnlocked = false
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.isUnlocked = true
                print("Biometrics unavailable: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func handleSuccessfulLogin() {
        isAuthenticated = true
        isUnlocked = true
        path = NavigationPath()
//        path.append(AppRoute.dashboard)
    }
    
    private func handleSuccessfulSignUp() {
        isAuthenticated = true
        isUnlocked = true
        path = NavigationPath()
//        path.append(AppRoute.dashboard)
    }
    
    private func handleLogout() {
//        isAuthenticated = false
//        path.removeLast(path.count)
        authViewModel.logout()
        isAuthenticated = false
        isUnlocked = false
        path = NavigationPath()
    }
}

#Preview {
    ContentView()
}
