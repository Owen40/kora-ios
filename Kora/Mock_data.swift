//
//  Mock_data.swift
//  Kora
//
//  Created by mac on 4/6/26.
//
import Foundation
import SwiftUI

// MARK: - Models

struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: Double
    let tags: [String]
    let imageName: String // Placeholder
}


// MARK: - Mock Data
struct MockData {
    
    static let menuItems = [
        MenuItem(name: "Cupcakes", description: "Vanilla cupcakes prepared with love", price: 150, tags: ["Dairy", "Eggs"], imageName: "cupcake"),
        MenuItem(name: "Minute Maid Apple", description: "Refreshing apple juice 500ml", price: 150, tags: [], imageName: "minutemaid"),
        MenuItem(name: "Milk tea", description: "Kenya's beverage prepared using milk, sugar and tea leaves", price: 150, tags: ["Dairy"], imageName: "milktea"),
        MenuItem(name: "Nice Icecream", description: "Nice Blend of Ice cream", price: 200, tags: ["Dairy"], imageName: "icecream")
    ]
}
