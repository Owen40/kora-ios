//
//  CartManager.swift
//  Kora
//
//  Created by mac on 4/7/26.
//
import Foundation
import Combine

class CartManager: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var deliveryFee: Double = 0.0
    @Published var estimatedTime: String = "30-40"
    @Published var restaurantId: String?
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var subtotal: Double {
        items.reduce(0) { $0 + ($1.dish.price.doubleValue * Double($1.quantity)) }
    }
    
    var tax: Double {
        return subtotal * 0.16 // 16% tax
    }
    
    var total: Double {
        return subtotal + deliveryFee + tax
    }
    
    func addToCart(dish: Dish) {
        if items.isEmpty {
            restaurantId = dish.restaurantId
        }
        
        if let index = items.firstIndex(where: { $0.dish.id == dish.id }) {
            items[index].quantity += 1
        } else {
            let cartItem = CartItem(dish: dish, quantity: 1)
            items.append(cartItem)
        }
    }
    
    func incrementQuantity(dishId: String) {
        if let index = items.firstIndex(where: { $0.dish.id == dishId }) {
            items[index].quantity += 1
        }
    }
    
    func decrementQuantity(dishId: String) {
        if let index = items.firstIndex(where: { $0.dish.id == dishId }) {
            if items[index].quantity > 1 {
                items[index].quantity -= 1
            } else {
                removeFromCart(dishId: dishId)
            }
        }
    }
    
    func removeFromCart(dishId: String) {
        items.removeAll { $0.dish.id == dishId }
        
        if items.isEmpty {
            restaurantId = nil
            deliveryFee = 0.0
            estimatedTime = "30-40"
        }
    }
    
    func clearCart() {
        items.removeAll()
        restaurantId = nil
        deliveryFee = 0.0
        estimatedTime = "30-40"
    }
    
    func updateDeliveryFee(fee: Double, time: String) {
        deliveryFee = fee
        estimatedTime = time
    }
}
