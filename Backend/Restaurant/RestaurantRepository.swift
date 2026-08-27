//
//  RestaurantRepository.swift
//  Kora
//
//  Created by mac on 4/6/26.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class RestaurantRepository: ObservableObject {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    // Note: Replace with your actual deployed backend URL or specific machine IP (e.g., http://192.168.x.x:3000)
    private let apiURL = "https://kora.bmsdyna.live/api/restaurants"
    
    func getRestaurants() -> AnyPublisher<[Restaurant], Error> {
        return Future<[Restaurant], Error> { promise in
            Task {
                do {
                    print("🚀 Fetching restaurants from Node.js backend...")
                    
                    // 1. Get current authenticated user
                    guard let user = self.auth.currentUser else {
                        throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
                    }
                    
                    // 2. Fetch Firebase JWT token to pass to the `protect` middleware
                    let token = try await user.getIDToken()
                    
                    guard let url = URL(string: self.apiURL) else {
                        throw URLError(.badURL)
                    }
                    
                    // 3. Configure the HTTP Request
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Accept")
                    
                    let (data, response) = try await URLSession.shared.data(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    
                    guard (200...299).contains(httpResponse.statusCode) else {
                        print("❌ Backend returned Error \(httpResponse.statusCode)")
                        throw URLError(.badServerResponse)
                    }
                    
                    // 4. Decode the { success, data: [] } response structure
                    let apiResponse = try JSONDecoder().decode(RestaurantResponse.self, from: data)
                    
                    if apiResponse.success {
                        print("✅ Successfully decoded \(apiResponse.data.count) restaurants")
                        promise(.success(apiResponse.data))
                    } else {
                        throw NSError(domain: "API", code: 400, userInfo: [NSLocalizedDescriptionKey: "API request failed"])
                    }
                } catch {
                    print("❌ Failed to fetch restaurants: \(error.localizedDescription)")
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main) // Ensure UI updates on the main thread
        .eraseToAnyPublisher()
    }
    
    // MARK: - Keep Existing Firestore Logic for Favourites
    func toggleFavourite(userId: String, restaurantId: String, isCurrentlyFavourite: Bool) {
        let favouritesRef = db.collection("users")
            .document(userId)
            .collection("favourites")
            .document(restaurantId)
        
        if isCurrentlyFavourite {
            favouritesRef.delete()
        } else {
            favouritesRef.setData(["timestamp": FieldValue.serverTimestamp()])
        }
    }
    
    func getFavouriteRestaurantIds(userId: String) -> AnyPublisher<Set<String>, Error> {
        let subject = PassthroughSubject<Set<String>, Error>()
        
        db.collection("users")
            .document(userId)
            .collection("favourites")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                let ids = Set(snapshot?.documents.map { $0.documentID } ?? [])
                subject.send(ids)
            }
        
        return subject.eraseToAnyPublisher()
    }
}
