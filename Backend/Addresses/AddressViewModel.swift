//
//  AddressViewModel.swift
//  Kora
//
//  Created by mac on 8/16/26.
//
import Foundation
import Combine

class AddressViewModel: ObservableObject {
    @Published private(set) var state: AddressState = .idle
    @Published private(set) var addresses: [Address] = []
    
    private let repository = AddressRepository()
    
    // MARK: - Fetch Addresses
    func fetchAddresses() {
        state = .loading
        repository.fetchAddresses { [weak self] fetchedAddresses in
            self?.addresses = fetchedAddresses
            self?.state = .success(nil)
        } onError: { [weak self] error in
            self?.state = .error(error)
        }
    }
    
    // MARK: - Create Address
    func createAddress(nickname: String?, street: String, city: String, longitude: Double? = nil, latitude: Double? = nil, deliveryInstructions: String? = nil) {
        state = .loading
        repository.createAddress(nickname: nickname, street: street, city: city, longitude: longitude, latitude: latitude, deliveryInstructions: deliveryInstructions) { [weak self] newAddress in
            // Append the new address and trigger a re-fetch to ensure order (default vs non-default) is respected
            self?.fetchAddresses()
            self?.state = .success("Address added successfully")
        } onError: { [weak self] error in
            self?.state = .error(error)
        }
    }
    
    // MARK: - Set Default Address
    func setDefaultAddress(id: String) {
        state = .loading
        repository.setDefaultAddress(id: id) { [weak self] _ in
            // Re-fetch to let the backend dictate the sorting order of the addresses
            self?.fetchAddresses()
            self?.state = .success("Default address updated")
        } onError: { [weak self] error in
            self?.state = .error(error)
        }
    }
    
    // MARK: - Delete Address
    func deleteAddress(id: String) {
        state = .loading
        repository.deleteAddress(id: id) { [weak self] in
            // Re-fetch to let backend determine which address becomes the new default if necessary
            self?.fetchAddresses()
            self?.state = .success("Address deleted")
        } onError: { [weak self] error in
            self?.state = .error(error)
        }
    }
    
    // MARK: - Utility
    func resetState() {
        state = .idle
    }
}
