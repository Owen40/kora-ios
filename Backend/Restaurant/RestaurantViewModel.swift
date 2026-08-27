//
//  RestaurantViewModel.swift
//  Kora
//
//  Created by mac on 4/6/26.
//
import Foundation
import Combine
import FirebaseAuth

class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var favouriteIds: Set<String> = []
    @Published var uiState: RestaurantUiState = .idle
    
    private let repository = RestaurantRepository()
    private let auth = Auth.auth()
    private var cancellables = Set<AnyCancellable>()
    
    var favouriteRestaurants: [Restaurant] {
        restaurants.filter { favouriteIds.contains($0.id ?? "") }
    }
    
    init() {
        fetchRestaurants()
        listenToFavourites()
    }
    
    func fetchRestaurants() {
        repository.getRestaurants()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.uiState = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] restaurants in
                self?.restaurants = restaurants
            }
            .store(in: &cancellables)
    }
    
    func listenToFavourites() {
        guard let userId = auth.currentUser?.uid else { return }
        
        repository.getFavouriteRestaurantIds(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.uiState = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] ids in
                self?.favouriteIds = ids
            }
            .store(in: &cancellables)
    }
    
    func toggleFavourite(restaurantId: String) {
        guard let userId = auth.currentUser?.uid else { return }
        let isFavourite = favouriteIds.contains(restaurantId)
        repository.toggleFavourite(userId: userId, restaurantId: restaurantId, isCurrentlyFavourite: isFavourite)
    }
    
    func removeFromFavourites(restaurantId: String) {
        guard let userId = auth.currentUser?.uid else { return }
        repository.toggleFavourite(userId: userId, restaurantId: restaurantId, isCurrentlyFavourite: true)
    }
    
    func resetState() {
        uiState = .idle
    }
}


