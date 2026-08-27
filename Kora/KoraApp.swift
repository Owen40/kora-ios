//
//  KoraApp.swift
//  Kora
//
//  Created by mac on 4/4/26.
//

import SwiftUI
import Firebase

@main
struct KoraApp: App {
    @StateObject private var cart = CartManager()
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cart)
        }
    }
}
