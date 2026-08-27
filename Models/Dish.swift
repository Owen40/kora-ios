//
//  Dish.swift
//  Kora
//
//  Created by mac on 4/7/26.
//
import Foundation
import FirebaseFirestore

struct Dish: Identifiable, Codable {
    @DocumentID var id: String?
    let restaurantId: String
    let name: String
    let category: String
    let price: String
    let description: String
    let prepTime: String
    let allergens: [String]
    let customization: String
    let isAvailable: Bool
    let imageUrl: String
    
    // Audit Logs
    let createdBy: String
    let createdAt: Date
    let updatedBy: String
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case restaurantId
        case name
        case category
        case price
        case description
        case prepTime
        case allergens
        case customization
        case isAvailable = "available"
        case imageUrl
        case createdBy
        case createdAt
        case updatedBy
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id)
        restaurantId = try container.decode(String.self, forKey: .restaurantId)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        
        // Handle price - could be String or Number
        if let priceString = try? container.decode(String.self, forKey: .price) {
            price = priceString
        } else if let priceNumber = try? container.decode(Int.self, forKey: .price) {
            price = String(priceNumber)
        } else {
            price = "0"
        }
        
        description = try container.decode(String.self, forKey: .description)
        prepTime = try container.decode(String.self, forKey: .prepTime)
        allergens = try container.decode([String].self, forKey: .allergens)
        customization = try container.decode(String.self, forKey: .customization)
        
        if let available = try? container.decode(Bool.self, forKey: .isAvailable) {
            isAvailable = available
        } else if let availableInt = try? container.decode(Int.self, forKey: .isAvailable) {
            isAvailable = availableInt == 1
        } else {
            isAvailable = true // Default to available
        }
        
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        createdBy = try container.decode(String.self, forKey: .createdBy)
        updatedBy = try container.decode(String.self, forKey: .updatedBy)
        
        // Handle createdAt - stored as milliseconds (Long) in Firestore
        if let createdAtMillis = try? container.decode(Int64.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtMillis) / 1000.0)
        } else if let createdAtTimestamp = try? container.decode(Timestamp.self, forKey: .createdAt) {
            createdAt = createdAtTimestamp.dateValue()
        } else {
            print("⚠️ Could not decode createdAt for dish: \(name)")
            createdAt = Date()
        }
        
        // Handle updatedAt - stored as milliseconds (Long) in Firestore
        if let updatedAtMillis = try? container.decode(Int64.self, forKey: .updatedAt) {
            updatedAt = Date(timeIntervalSince1970: TimeInterval(updatedAtMillis) / 1000.0)
        } else if let updatedAtTimestamp = try? container.decode(Timestamp.self, forKey: .updatedAt) {
            updatedAt = updatedAtTimestamp.dateValue()
        } else {
            updatedAt = Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(restaurantId, forKey: .restaurantId)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(price, forKey: .price)
        try container.encode(description, forKey: .description)
        try container.encode(prepTime, forKey: .prepTime)
        try container.encode(allergens, forKey: .allergens)
        try container.encode(customization, forKey: .customization)
        try container.encode(isAvailable, forKey: .isAvailable)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(createdBy, forKey: .createdBy)
        try container.encode(updatedBy, forKey: .updatedBy)
        
        // Convert Date to milliseconds for Firestore
        let createdAtMillis = Int64(createdAt.timeIntervalSince1970 * 1000)
        let updatedAtMillis = Int64(updatedAt.timeIntervalSince1970 * 1000)
        
        try container.encode(createdAtMillis, forKey: .createdAt)
        try container.encode(updatedAtMillis, forKey: .updatedAt)
    }
}

extension Dish {
    init(restaurantId: String, name: String, category: String, price: String, description: String, prepTime: String, allergens: [String], customization: String, isAvailable: Bool, imageUrl: String, createdBy: String, updatedBy: String) {
        self.restaurantId = restaurantId
        self.name = name
        self.category = category
        self.price = price
        self.description = description
        self.prepTime = prepTime
        self.allergens = allergens
        self.customization = customization
        self.isAvailable = isAvailable
        self.imageUrl = imageUrl
        self.createdBy = createdBy
        self.updatedBy = updatedBy
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
