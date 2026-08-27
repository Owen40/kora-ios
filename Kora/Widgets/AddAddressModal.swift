//
//  AddAddressModal.swift
//  Kora
//
//  Created by mac on 8/16/26.
//
import SwiftUI

struct AddAddressModal: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme
    
    // Pass the parent view model so the modal can trigger the network request
    @ObservedObject var viewModel: AddressViewModel
    
    @State private var nickname = ""
    @State private var street = ""
    @State private var city = ""
    @State private var deliveryInstructions = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add New Address")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Theme.text(for: scheme))
                        Text("Where should we deliver your food?")
                            .font(.subheadline)
                            .foregroundColor(Theme.text(for: scheme).opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    
                    GlassTextField(label: "Nickname (Optional)", placeholder: "e.g. Home, Office", text: $nickname)
                    
                    GlassTextField(label: "Street Address", placeholder: "e.g. 123 Main St", text: $street)
                    
                    GlassTextField(label: "City", placeholder: "e.g. Nairobi", text: $city)
                    
                    GlassTextField(label: "Delivery Instructions (Optional)", placeholder: "e.g. Leave at reception", text: $deliveryInstructions)
                    
                    Spacer().frame(height: 20)
                    
                    PrimaryButton(title: "Save Address") {
                        // The backend requires street and city[cite: 3]
                        if street.isEmpty || city.isEmpty {
                            // You can add local validation/snackbar here if needed
                            return
                        }
                        
                        let safeNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : nickname
                        let safeInstructions = deliveryInstructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : deliveryInstructions
                        
                        viewModel.createAddress(
                            nickname: safeNickname,
                            street: street,
                            city: city,
                            deliveryInstructions: safeInstructions
                        )
                    }
                    
                }
                .padding(.horizontal, 24)
            }
            .background(Theme.background(for: scheme).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.text(for: scheme).opacity(0.6))
                            .font(.title3)
                    }
                }
            }
        }
        // Automatically dismiss the modal when the address is successfully saved
        .onReceive(viewModel.$state) { state in
            if case .success = state {
                dismiss()
                viewModel.resetState() // Clear the success message
            }
        }
    }
}
