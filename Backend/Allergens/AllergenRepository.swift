//
//  AllergenRepository.swift
//  Kora
//
//  Created by mac on 8/16/26.
//
import Foundation
import Combine

enum AllergenState: Equatable {
    case idle
    case loading
    case fetchSuccess
    case saveSuccess
    case error(String)
}

class AllergenRepository {
    private let apiClient = APIClient.shared
    
    func getGlobalAllergens(onSuccess: @escaping ([GlobalAllergen]) -> Void, onError: @escaping (String) -> Void) {
        apiClient.request(endpoint: "/allergens", method: "GET") { result in
            // Handle parsing JSON to [GlobalAllergen] here
            // Similar to how AuthRepository handles getCurrentUserData success parsing
        }
    }
    
    func saveUserAllergens(allergenIds: [String], onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        let body: [String: Any] = ["allergen_ids": allergenIds]
        apiClient.request(endpoint: "/users/me/allergens", method: "PUT", body: body) { result in
            switch result {
            case .success(let json):
                if let success = json["success"] as? Bool, success {
                    onSuccess()
                } else {
                    onError(json["message"] as? String ?? "Failed to save allergens")
                }
            case .failure(let error):
                onError(error.localizedDescription)
            }
        }
    }
}
