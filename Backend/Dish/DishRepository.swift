//
//  DishRepository.swift
//  Kora
//
//  Created by mac on 4/7/26.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class DishRepository: ObservableObject {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    func getDishes(restaurantId: String) -> AnyPublisher<[Dish], Error> {
        let subject = PassthroughSubject<[Dish], Error>()
        
        print("🟢 DishRepository: Fetching dishes for restaurant: \(restaurantId)")
        
        db.collection("dishes")
            .whereField("restaurantId", isEqualTo: restaurantId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("🔴 DishRepository Error: \(error.localizedDescription)")
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("🟡 No dishes found for restaurant: \(restaurantId)")
                    subject.send([])
                    return
                }
                
                print("🟢 Found \(documents.count) dish documents for restaurant: \(restaurantId)")
                
                // Debug: Print each document
                for document in documents {
                    print("📄 Dish Document ID: \(document.documentID)")
                    print("📄 Dish Data: \(document.data())")
                }
                
                let dishes = documents.compactMap { document -> Dish? in
                    do {
                        let dish = try document.data(as: Dish.self)
                        print("✅ Successfully decoded dish: \(dish.name)")
                        return dish
                    } catch {
                        print("🔴 Failed to decode dish: \(error)")
                        print("Raw data: \(document.data())")
                        return nil
                    }
                }
                
                print("🟢 Successfully decoded \(dishes.count) dishes")
                subject.send(dishes)
            }
        
        return subject.eraseToAnyPublisher()
    }
}
