//
//  OrderRepository.swift
//  Kora
//
//  Created by mac on 4/7/26.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class OrderRepository: ObservableObject {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    func getRestaurantDetails(restaurantId: String) -> AnyPublisher<Restaurant?, Error> {
        let subject = PassthroughSubject<Restaurant?, Error>()
        
        db.collection("restaurants").document(restaurantId).getDocument { document, error in
            if let error = error {
                subject.send(completion: .failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                subject.send(nil)
                return
            }
            
            do {
                let restaurant = try document.data(as: Restaurant.self, decoder: Firestore.Decoder())
                subject.send(restaurant)
            } catch {
                subject.send(completion: .failure(error))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func placeOrder(
        userId: String,
        restaurantId: String,
        items: [OrderItem],
        subtotal: Double,
        tax: Double,
        deliveryFee: Double,
        total: Double,
        paymentMethod: String,
        address: Address,
        onSuccess: @escaping (String) -> Void,
        onError: @escaping (String) -> Void
    ) {
        let orderId = "ORD-\(Int.random(in: 100...9999))"
        let timestamp = Date().timeIntervalSince1970 * 1000
        
        let batch = db.batch()
        let orderRef = db.collection("orders").document(orderId)
        
        let orderData: [String: Any] = [
            "id": orderId,
            "userId": userId,
            "restaurantId": restaurantId,
            "items": items.map { [
                "dishId": $0.dishId,
                "name": $0.name,
                "price": $0.price,
                "quantity": $0.quantity
            ]},
            "subtotal": subtotal,
            "tax": tax,
            "deliveryFee": deliveryFee,
            "total": total,
            "paymentMethod": paymentMethod,
            "paymentStatus": "Unpaid",
            "deliveryAddress": [
                "id": address.id,
                "userId": userId,
                "nickname": address.nickname ?? "",
                "street": address.street,
                "city": address.city,
                "latitude": address.latitude ?? 0.0,
                "longitude": address.longitude ?? 0.0
            ],
            "status": "Pending",
            "createdAt": timestamp,
            "updatedAt": timestamp
        ]
        batch.setData(orderData, forDocument: orderRef)
        
        for item in items {
            let itemId = UUID().uuidString
            let itemRef = orderRef.collection("order-items").document(itemId)
            
            let itemData: [String: Any] = [
                "id": itemId,
                "orderId": orderId,
                "dishId": item.dishId,
                "name": item.name,
                "price": item.price,
                "quantity": item.quantity,
                "imageUrl": item.imageUrl ?? ""
            ]
            batch.setData(itemData, forDocument: itemRef)
        }
        
        batch.commit { error in
            DispatchQueue.main.async {
                if let error = error {
                    onError(error.localizedDescription)
                } else {
                    onSuccess(orderId)
                }
            }
        }
        
    }
}

extension Firestore {
    static func Decoder() -> Firestore.Decoder {
        let decoder = Firestore.Decoder()
        return decoder
    }
}
