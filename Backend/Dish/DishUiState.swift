//
//  DishUiState.swift
//  Kora
//
//  Created by mac on 4/7/26.
//
import Foundation

enum DishUiState: Equatable {
    case idle
    case loading
    case success
    case error(String)
    
    static func == (lhs: DishUiState, rhs: DishUiState) -> Bool {
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
