//
//  RestaurantUiState.swift
//  Kora
//
//  Created by mac on 4/6/26.
//
import Foundation

enum RestaurantUiState: Equatable {
    case idle
    case loading
    case success
    case error(String)
    
    static func == (lhs: RestaurantUiState, rhs: RestaurantUiState) -> Bool {
        switch (lhs, rhs) {
                case (.idle, .idle):
                    return true
                case (.loading, .loading):
                    return true
                case (.success, .success):
                    return true
                case (.error(let lhsMessage), .error(let rhsMessage)):
                    return lhsMessage == rhsMessage
                default:
                    return false
                }
    }
}
