//
//  Restaurants.swift
//  Kora
//
//  Created by mac on 4/6/26.
//
import Foundation
import FirebaseFirestore
import SwiftUI

struct RestaurantResponse: Codable {
    let success: Bool
    let count: Int?
    let data: [Restaurant]
}

struct Restaurant: Identifiable, Codable {
    var id: String? // Changed from @DocumentID
    let name: String
    let cuisine: String?
    let deliveryFee: String
    let estTime: String
    let openingTime: String
    let closingTime: String
    let imageUrl: String?
    let phone: String?
    let dishCount: Int?
    
    // Audit Logs
    let createdBy: String?
    let createdAt: Date
    let updatedBy: String?
    let updatedAt: Date
    
    var isClosed: Bool {
        return false // Customize as needed
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, cuisine, phone
        case deliveryFee = "delivery_fee"
        case estTime = "estimated_time"
        case openingTime = "opening_time"
        case closingTime = "closing_time"
        case imageUrl = "image_url"
        case dishCount = "dish_count"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedBy = "updated_by"
        case updatedAt = "updated_at"
    }
    
    // Custom Decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Use standard String types instead of Firestore IDs
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = String(idInt) // If Postgres id is an auto-increment integer
        } else {
            id = try container.decodeIfPresent(String.self, forKey: .id) // If Postgres is UUID
        }
        
        name = try container.decode(String.self, forKey: .name)
        cuisine = try container.decodeIfPresent(String.self, forKey: .cuisine)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        
        // Flexible decoding for numeric strings
        if let feeStr = try? container.decode(String.self, forKey: .deliveryFee) {
            deliveryFee = feeStr
        } else if let feeNum = try? container.decode(Double.self, forKey: .deliveryFee) {
            deliveryFee = String(format: "%.2f", feeNum)
        } else {
            deliveryFee = "0"
        }

        if let estStr = try? container.decode(String.self, forKey: .estTime) {
            estTime = estStr
        } else if let estNum = try? container.decode(Int.self, forKey: .estTime) {
            estTime = String(estNum)
        } else {
            estTime = "30"
        }
        
        openingTime = try container.decode(String.self, forKey: .openingTime)
        closingTime = try container.decode(String.self, forKey: .closingTime)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        dishCount = try container.decodeIfPresent(Int.self, forKey: .dishCount)
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        updatedBy = try container.decodeIfPresent(String.self, forKey: .updatedBy)
        
        // Node.js (PostgreSQL) typically returns ISO8601 Date strings
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let createdStr = try? container.decode(String.self, forKey: .createdAt),
           let date = dateFormatter.date(from: createdStr) ?? ISO8601DateFormatter().date(from: createdStr) {
            createdAt = date
        } else {
            createdAt = Date()
        }
        
        if let updatedStr = try? container.decode(String.self, forKey: .updatedAt),
           let date = dateFormatter.date(from: updatedStr) ?? ISO8601DateFormatter().date(from: updatedStr) {
            updatedAt = date
        } else {
            updatedAt = Date()
        }
    }
}
extension Restaurant {
    init(name: String, cuisine: String, deliveryFee: String, estTime: String, openingTime: String, closingTime: String, imageUrl: String, phone: String? = nil, dishCount: Int? = nil, createdBy: String, updatedBy: String) {
        self.name = name
        self.cuisine = cuisine
        self.phone = phone
        self.deliveryFee = deliveryFee
        self.estTime = estTime
        self.openingTime = openingTime
        self.closingTime = closingTime
        self.imageUrl = imageUrl
        self.dishCount = dishCount
        self.createdBy = createdBy
        self.updatedBy = updatedBy
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func isRestaurantOpen() -> Bool {
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        // Parse opening and closing times
        guard let openingDate = dateFormatter.date(from: openingTime),
              let closingDate = dateFormatter.date(from: closingTime) else {
            return true // Default to open if can't parse
        }
        
        // Get current time components
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.hour, .minute], from: currentTime)
        let openingComponents = calendar.dateComponents([.hour, .minute], from: openingDate)
        let closingComponents = calendar.dateComponents([.hour, .minute], from: closingDate)
        
        guard let currentHour = currentComponents.hour,
              let currentMinute = currentComponents.minute,
              let openingHour = openingComponents.hour,
              let openingMinute = openingComponents.minute,
              let closingHour = closingComponents.hour,
              let closingMinute = closingComponents.minute else {
            return true
        }
        
        let currentMinutes = currentHour * 60 + currentMinute
        let openingMinutes = openingHour * 60 + openingMinute
        let closingMinutes = closingHour * 60 + closingMinute
        
        // Handle times that cross midnight
        if closingMinutes < openingMinutes {
            return currentMinutes >= openingMinutes || currentMinutes <= closingMinutes
        } else {
            return currentMinutes >= openingMinutes && currentMinutes <= closingMinutes
        }
    }
    
    func getTimeStatusText() -> String {
        if isRestaurantOpen() {
            return "Closes at \(closingTime)"
        } else {
            return "Opens at \(openingTime)"
        }
    }
    
    func getTimeStatusIcon() -> String {
        if isRestaurantOpen() {
            return "clock.fill"
        } else {
            return "clock.badge.xmark.fill"
        }
    }
    
    func getTimeStatusColor(for scheme: ColorScheme) -> Color {
        if isRestaurantOpen() {
            return Theme.accent(for: scheme)
        } else {
            return .red
        }
    }
}
