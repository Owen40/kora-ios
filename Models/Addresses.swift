//
//  Addresses.swift
//  Kora
//
//  Created by mac on 4/7/26.
//
import Foundation

struct AddressResponse: Codable {
    let success: Bool
    let count: Int?
    let addresses: [Address]?
    let address: Address?
}

struct Address: Identifiable, Codable, Hashable {
    let id: String
    let nickname: String?
    let street: String
    let city: String
    let longitude: Double?
    let latitude: Double?
    let deliveryInstructions: String?
    let isDefault: Bool
}
