//
//  DishViewModel.swift
//  Kora
//
//  Created by mac on 4/7/26.
//
import Foundation
import Combine

class DishViewModel: ObservableObject {
    @Published var dishes: [Dish] = []
    @Published var uiState: DishUiState = .idle
    
    private let repository = DishRepository()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchDishes(restaurantId: String) {
        uiState = .loading
        
        repository.getDishes(restaurantId: restaurantId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.uiState = .error(error.localizedDescription)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] dishes in
                self?.dishes = dishes
                self?.uiState = .success
            })
            .store(in: &cancellables)
    }
    
    func resetState() {
        uiState = .idle
    }
}

