//
//  UserOrdersViewModel.swift
//  Kora
//
//  Created by mac on 4/10/26.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

struct UserOrderUiState: Identifiable {
    let id = UUID()
    let order: Order // Assumes you have your Order model defined
    let restaurantName: String
    let itemCount: Int
    let formattedDate: String
    let itemDescription: String // Holds text like "2x Burger, 1x Fries"
    
    let imageUrl: String
    
    // UI Helpers based on your screenshots
    var statusText: String {
        return order.status.rawValue
    }
    
    var isCancelled: Bool {
        return order.status == .cancelled
    }
}

@MainActor
class UserOrdersViewModel: ObservableObject {
    @Published var uiState: [UserOrderUiState] = []
    @Published var isLoading: Bool = false
    @Published var selectedOrderItems: [OrderItem] = [] // Assumes OrderItem model exists
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    // private let repository = OrderRepository() // Uncomment if you have translated your OrderRepository
    
    init() {
        fetchMyOrders()
    }
    
    func fetchMyOrders() {
        guard let userId = auth.currentUser?.uid else { return }
        isLoading = true
        
        Task {
            do {
                let snapshot = try await db.collection("orders").whereField("userId", isEqualTo: userId).getDocuments()
                let rawOrders = snapshot.documents.compactMap { try? $0.data(as: Order.self) }
                
                var processedOrders: [UserOrderUiState] = []
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy • h:mm a" // e.g., Oct 24, 2023 • 7:30 PM
                
                for order in rawOrders {
                    // Fetch restaurant details
                    var restaurantName = "Unknown Restaurant"
                    var restaurantImageUrl = ""
                    
                    // CHANGED: restaurantId is a non-optional string in your model, no need for `if let`
                    let restId = order.restaurantId
                    if let restDoc = try? await db.collection("restaurants").document(restId).getDocument() {
                        restaurantName = restDoc.data()?["name"] as? String ?? "Unknown Restaurant"
                        // Fetch the image URL from the restaurant to display in the order card
                        restaurantImageUrl = restDoc.data()?["imageUrl"] as? String ?? ""
                    }
                    
                    // CHANGED: Your Order model already contains the embedded items array!
                    // We don't need to perform an extra database fetch here.
                    let itemsSnapshot = try? await db.collection("orders").document(order.id ?? "").collection("order-items").getDocuments()
                    let items = itemsSnapshot?.documents.compactMap { try? $0.data(as: OrderItem.self) } ?? []
                    
                    let itemCount = items.count
                    let descriptions = items.map { "\($0.quantity)x \($0.name)" }
                    let itemDescription = descriptions.joined(separator: ", ")
                    
                    // CHANGED: order.createdAt is already a Date object! No conversion needed.
                    let orderDate = Date(timeIntervalSince1970: order.createdAt / 1000)
                    
                    processedOrders.append(
                        UserOrderUiState(
                            order: order,
                            restaurantName: restaurantName,
                            itemCount: itemCount,
                            formattedDate: dateFormatter.string(from: orderDate),
                            itemDescription: itemDescription.isEmpty ? "Items not found" : itemDescription,
                            imageUrl: restaurantImageUrl // CHANGED: Passed the fetched image URL to the UI state
                        )
                    )
                }
                
                // Sort to show newest first
                self.uiState = processedOrders.sorted(by: { $0.order.createdAt > $1.order.createdAt })
                
            } catch {
                print("Error loading orders: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
    
    func fetchOrderItemsForSheet(orderId: String) {
        Task {
            do {
                let snapshot = try await db.collection("orders").document(orderId).collection("order-items").getDocuments()
                self.selectedOrderItems = snapshot.documents.compactMap { try? $0.data(as: OrderItem.self) }
            } catch {
                print("Error fetching items for sheet: \(error.localizedDescription)")
                self.selectedOrderItems = []
            }
        }
    }
}
