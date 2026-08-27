//
//  CartItem.swift
//  Kora
//
//  Created by mac on 4/7/26.
//
import Foundation

struct CartItem: Identifiable {
    let id = UUID()
    let dish: Dish
    var quantity: Int
    
    var totalPrice: Double {
        return dish.price.doubleValue * Double(quantity)
    }
}

// Extension to convert String price to Double
extension String {
    var doubleValue: Double {
        return Double(self) ?? 0.0
    }
}
