//
//  AddressView.swift
//  Kora
//
//  Created by mac on 8/16/26.
//
import SwiftUI

struct AddressesView: View {
    @Environment(\.colorScheme) var scheme
    @StateObject private var viewModel = AddressViewModel()
    
    @State private var showAddAddressModal = false
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""
    
    var body: some View {
        VStack {
            if viewModel.state == .loading && viewModel.addresses.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.addresses.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "mappin.slash")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.text(for: scheme).opacity(0.3))
                    Text("No addresses saved yet.")
                        .font(.headline)
                        .foregroundColor(Theme.text(for: scheme).opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.addresses) { address in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(address.nickname ?? "Saved Address")
                                    .font(.headline)
                                    .foregroundColor(Theme.text(for: scheme))
                                
                                if address.isDefault {
                                    Text("Default")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Theme.accent(for: scheme).opacity(0.2))
                                        .foregroundColor(Theme.accent(for: scheme))
                                        .cornerRadius(6)
                                }
                                
                                Spacer()
                                
                                if !address.isDefault {
                                    Button(action: {
                                        viewModel.setDefaultAddress(id: address.id)
                                    }) {
                                        Text("Set Default")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            Text("\(address.street), \(address.city)")
                                .font(.subheadline)
                                .foregroundColor(Theme.text(for: scheme).opacity(0.6))
                            
                            if let instructions = address.deliveryInstructions {
                                Text("Note: \(instructions)")
                                    .font(.caption)
                                    .foregroundColor(Theme.text(for: scheme).opacity(0.5))
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Theme.background(for: scheme))
                    }
                    .onDelete(perform: deleteAddress)
                }
                .listStyle(PlainListStyle())
            }
            
            Spacer()
            
            PrimaryButton(title: "Add New Address") {
                showAddAddressModal = true
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Theme.background(for: scheme).ignoresSafeArea())
        .navigationTitle("My Addresses")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchAddresses()
        }
        .sheet(isPresented: $showAddAddressModal) {
            AddAddressModal(viewModel: viewModel)
        }
        .onReceive(viewModel.$state) { state in
            switch state {
            case .error(let message):
                snackbarMessage = message
                showSnackbar = true
                viewModel.resetState()
            case .success(let message):
                if let msg = message {
                    snackbarMessage = msg
                    showSnackbar = true
                    viewModel.resetState()
                }
            default:
                break
            }
        }
        .snackbar(isPresented: $showSnackbar, message: snackbarMessage)
    }
    
    private func deleteAddress(at offsets: IndexSet) {
        for index in offsets {
            let addressId = viewModel.addresses[index].id
            viewModel.deleteAddress(id: addressId)
        }
    }
}
