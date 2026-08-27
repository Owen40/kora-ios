//
//  User.swift
//  Kora
//
//  Created by mac on 4/6/26.
//
import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    let uid: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let role: String
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case uid
        case firstName
        case lastName
        case email
        case phone
        case role
        case createdAt
        case updatedAt
    }
    
    init(uid: String, firstName: String, lastName: String, email: String, phone: String, role: String, createdAt: Date, updatedAt: Date) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // For Firestore decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decode(String.self, forKey: .phone)
        role = try container.decode(String.self, forKey: .role)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
    
    // For Firestore encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encode(role, forKey: .role)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}
