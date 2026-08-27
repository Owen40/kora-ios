//
//  Allergens.swift
//  Kora
//
//  Created by mac on 8/16/26.
//
import Foundation

struct AllergenResponse: Codable {
    let success: Bool
    let count: Int?
    let allergens: [Allergen]
}

struct Allergen: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String?
    
    // Maps backend keys to Swift properties if needed
    enum CodingKeys: String, CodingKey {
        case id = "allergen_id" // Use this if fetching from user_allergens
        case name, description
    }
}

// For the global allergens list which returns 'id' directly
struct GlobalAllergen: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String?
}
