//
//  Orders.swift
//  Kora
//
//  Created by mac on 4/7/26.
//
import Foundation
import FirebaseFirestore

struct Order: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let restaurantId: String
    let items: [OrderItem]
    let subtotal: Double
    let tax: Double
    let deliveryFee: Double
    let total: Double
    let paymentMethod: String
    let paymentStatus: String?
    let deliveryAddress: Address
    let status: OrderStatus
    let createdAt: Double
    let updatedAt: Double
    
    enum OrderStatus: String, Codable {
        case pending = "Pending"
        case confirmed = "Confirmed"
        case preparing = "Preparing"
        case outForDelivery = "Out for Delivery"
        case delivered = "Delivered"
        case cancelled = "Cancelled"
    }
}

struct OrderItem: Codable {
    @DocumentID var id: String?
    let dishId: String
    let name: String
    let price: Double
    let quantity: Int
    let imageUrl: String?
}
