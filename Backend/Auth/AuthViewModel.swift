//
//  AuthViewModel.swift
//  Kora
//
//  Created by mac on 4/6/26.
//
import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published private(set) var authState: AuthState = .idle
    @Published private(set) var currentUser: User?
    
    private let repository = AuthRepository()
    
    var isUserLoggedIn: Bool {
        return repository.currentUserUid != nil
    }
    
    func signUp(firstName: String, lastName: String, email: String, phone: String, password: String) {
        authState = .loading
        repository.signUp(firstName: firstName, lastName: lastName, email: email, phone: phone, password: password) { [weak self] in
            self?.authState = .success("user")
        } onError: { [weak self] error in
            self?.authState = .error(error)
        }
    }
    
    func signIn(email: String, password: String) {
        authState = .loading
        
        repository.signIn(email: email, password: password) { [weak self] role, requiresOtp, returnedEmail in
            if requiresOtp, let validEmail = returnedEmail {
                self?.authState = .requiresOtp(validEmail)
            } else {
                self?.authState = .success(role)
            }
        } onError: { [weak self] error in
            self?.authState = .error(error)
        }
    }
    
    func verifyOtp(email: String, otpCode: String) {
        authState = .loading
        
        repository.verifyOtp(email: email, otpCode: otpCode) { [weak self] role in
            self?.authState = .success(role)
        } onError: { [weak self] error in
            self?.authState = .error(error)
        }
    }
    
    func resetPassword(email: String) {
        authState = .loading
        repository.sendPasswordReset(email: email) { [weak self] in
            self?.authState = .passwordResetEmailSent
        } onError: { [weak self] error in
            self?.authState = .error(error)
        }
    }
    
    func fetchCurrentUser() {
        repository.getCurrentUserData { [weak self] user in
            self?.currentUser = user
        } onError: { [weak self] error in
            self?.authState = .error(error)
        }
    }
    
    func logout() {
        repository.logout()
        authState = .idle
        currentUser = nil
    }
    
    func resetState() {
        authState = .idle
    }
}
