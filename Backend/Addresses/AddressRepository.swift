//
//  AddressRepository.swift
//  Kora
//
//  Created by mac on 8/16/26.
//

import Foundation

enum AddressState: Equatable {
    case idle
    case loading
    case success(String?) // Optional success message for UI snackbars
    case error(String)
}

class AddressRepository {
    private let apiClient = APIClient.shared
    
    // MARK: - Fetch All Addresses
    func fetchAddresses(onSuccess: @escaping ([Address]) -> Void, onError: @escaping (String) -> Void) {
        apiClient.request(endpoint: "/addresses", method: "GET") { result in
            switch result {
            case .success(let json):
                if let success = json["success"] as? Bool, success,
                   let addressesData = json["addresses"] as? [[String: Any]] {
                    do {
                        // Convert the dictionary array back to Data to leverage Codable
                        let data = try JSONSerialization.data(withJSONObject: addressesData)
                        let addresses = try JSONDecoder().decode([Address].self, from: data)
                        onSuccess(addresses)
                    } catch {
                        onError("Failed to parse addresses data.")
                    }
                } else {
                    onError(json["message"] as? String ?? "Failed to fetch addresses.")
                }
            case .failure(let error):
                onError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Create Address
    func createAddress(nickname: String?, street: String, city: String, longitude: Double?, latitude: Double?, deliveryInstructions: String?, onSuccess: @escaping (Address) -> Void, onError: @escaping (String) -> Void) {
        
        var body: [String: Any] = [
            "street": street,
            "city": city
        ]
        
        if let nickname = nickname { body["nickname"] = nickname }
        if let longitude = longitude { body["longitude"] = longitude }
        if let latitude = latitude { body["latitude"] = latitude }
        if let deliveryInstructions = deliveryInstructions { body["delivery_instructions"] = deliveryInstructions }
        
        apiClient.request(endpoint: "/addresses", method: "POST", body: body) { result in
            switch result {
            case .success(let json):
                if let success = json["success"] as? Bool, success,
                   let addressData = json["address"] as? [String: Any] {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: addressData)
                        let address = try JSONDecoder().decode(Address.self, from: data)
                        onSuccess(address)
                    } catch {
                        onError("Failed to parse created address.")
                    }
                } else {
                    onError(json["message"] as? String ?? "Failed to create address.")
                }
            case .failure(let error):
                onError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Set Default Address
    func setDefaultAddress(id: String, onSuccess: @escaping (Address) -> Void, onError: @escaping (String) -> Void) {
        apiClient.request(endpoint: "/addresses/\(id)/default", method: "PATCH") { result in
            switch result {
            case .success(let json):
                if let success = json["success"] as? Bool, success,
                   let addressData = json["address"] as? [String: Any] {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: addressData)
                        let address = try JSONDecoder().decode(Address.self, from: data)
                        onSuccess(address)
                    } catch {
                        onError("Failed to parse updated address.")
                    }
                } else {
                    onError(json["message"] as? String ?? "Failed to set default address.")
                }
            case .failure(let error):
                onError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Delete Address
    func deleteAddress(id: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        apiClient.request(endpoint: "/addresses/\(id)", method: "DELETE") { result in
            switch result {
            case .success(let json):
                if let success = json["success"] as? Bool, success {
                    onSuccess()
                } else {
                    onError(json["message"] as? String ?? "Failed to delete address.")
                }
            case .failure(let error):
                onError(error.localizedDescription)
            }
        }
    }
}
