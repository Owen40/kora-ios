//
//  AllergenViewModel.swift
//  Kora
//
//  Created by mac on 8/16/26.
//
import Foundation
import Combine

class AllergenViewModel: ObservableObject {
    @Published private(set) var allergenState: AllergenState = .idle
    @Published private(set) var availableAllergens: [GlobalAllergen] = []
    
    private let repository = AllergenRepository()
    
    func fetchAllergens() {
        allergenState = .loading
        repository.getGlobalAllergens { [weak self] allergens in
            self?.availableAllergens = allergens
            self?.allergenState = .fetchSuccess
        } onError: { [weak self] error in
            self?.allergenState = .error(error)
        }
    }
    
    func saveSelections(allergenIds: [String]) {
        allergenState = .loading
        repository.saveUserAllergens(allergenIds: allergenIds) { [weak self] in
            self?.allergenState = .saveSuccess
        } onError: { [weak self] error in
            self?.allergenState = .error(error)
        }
    }
    
    func resetState() {
        allergenState = .idle
    }
}
