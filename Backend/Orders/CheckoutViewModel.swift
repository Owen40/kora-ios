//
//  CheckoutViewModel.swift
//  Kora
//
//  Created by mac on 4/7/26.
//
import Foundation
import Combine

enum CheckoutUiState: Equatable {
    case idle
    case loading
    case success(String) // orderId
    case error(String)
}

class CheckoutViewModel: ObservableObject {
    @Published var uiState: CheckoutUiState = .idle
    @Published var deliveryFee: Double = 0.0
    @Published var estimatedTime: String = "40-45"
    @Published var isFetchingFee: Bool = false
    
    private let repository = OrderRepository()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchDeliveryFee(restaurantId: String) {
        guard !restaurantId.isEmpty else { return }
        
        isFetchingFee = true
        
        repository.getRestaurantDetails(restaurantId: restaurantId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isFetchingFee = false
                if case .failure(let error) = completion {
                    print("Error fetching restaurant: \(error)")
                }
            }, receiveValue: { [weak self] restaurant in
                guard let restaurant = restaurant else { return }
                
                // Parse delivery fee
                let feeString = restaurant.deliveryFee
                let fee = Double(feeString) ?? 0.0
                self?.deliveryFee = fee
                
                // Set estimated time
                if !restaurant.estTime.isEmpty {
                    self?.estimatedTime = restaurant.estTime
                }
            })
            .store(in: &cancellables)
    }
    
    func submitOrder(
        cartItems: [CartItem],
        subtotal: Double,
        tax: Double,
        total: Double,
        paymentMethod: String,
        address: Address,
        userId: String,
        restaurantId: String
    ) {
        guard !cartItems.isEmpty else {
            uiState = .error("Cart is empty")
            return
        }
        
        // Create order items
        let orderItems = cartItems.map { cartItem in
            let cleanPrice = cartItem.dish.price.replacingOccurrences(of: "[^0-9", with: "", options: .regularExpression)
            let priceDouble = Double(cleanPrice) ?? 0.0
            
            return OrderItem(
                dishId: cartItem.dish.id ?? "",
                name: cartItem.dish.name,
                price: priceDouble,
                quantity: cartItem.quantity,
                imageUrl: cartItem.dish.imageUrl
            )
        }
        
        uiState = .loading
        
        repository.placeOrder(
            userId: userId,
            restaurantId: restaurantId,
            items: orderItems,
            subtotal: subtotal,
            tax: tax,
            deliveryFee: deliveryFee,
            total: total,
            paymentMethod: paymentMethod,
            address: address
        ) { [weak self] orderId in
            self?.uiState = .success(orderId)
        } onError: { [weak self] error in
            self?.uiState = .error(error)
        }
    }
    
    func resetState() {
        uiState = .idle
    }
}
