//
//  AuthRepository.swift
//  Kora
//

import Foundation

class AuthRepository {
    private let baseURL = "https://kora.bmsdyna.live/api"
    
    // MARK: - Token Management
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "jwt_token")
    }
    
    private func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "jwt_token")
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "jwt_token")
    }
    
    var currentUserUid: String? {
        return getToken() != nil ? "authenticated" : nil
    }
    
    // MARK: - Network Helper
    private func request(endpoint: String, method: String = "POST", body: [String: Any]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else { return }
        
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = getToken() {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        URLSession.shared.dataTask(with: req) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
                return
            }
            DispatchQueue.main.async { completion(.success(json)) }
        }.resume()
    }
    
    // MARK: - Sign Up
    func signUp(firstName: String, lastName: String, email: String, phone: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        let body: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "phone": phone,
            "password": password
        ]
        
        request(endpoint: "/auth/register", body: body) { [weak self] result in
            switch result {
            case .success(let json):
                if let success = json["success"] as? Bool, success {
                    if let token = json["token"] as? String {
                        self?.saveToken(token)
                    }
                    onSuccess()
                } else {
                    onError(json["message"] as? String ?? "Registration failed")
                }
            case .failure(let error):
                onError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String, onSuccess: @escaping (String, Bool, String?) -> Void, onError: @escaping (String) -> Void) {
        let body: [String: Any] = ["email": email, "password": password]
        
        request(endpoint: "/auth/login", body: body) { result in
            switch result {
            case .success(let json):
                if let success = json["success"] as? Bool, success {
                    // Node backend returns requiresOtp and the user's email
                    let requiresOtp = json["requiresOtp"] as? Bool ?? false
                    let resEmail = json["email"] as? String
                    onSuccess("user", requiresOtp, resEmail)
                } else {
                    onError(json["message"] as? String ?? "Login failed")
                }
            case .failure(let error):
                onError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Verify OTP
    func verifyOtp(email: String, otpCode: String, onSuccess: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        let body: [String: Any] = ["email": email, "otp_code": otpCode]
        
        request(endpoint: "/auth/verify-otp", body: body) { [weak self] result in
            switch result {
            case .success(let json):
                if let success = json["success"] as? Bool, success {
                    if let token = json["token"] as? String {
                        self?.saveToken(token)
                    }
                    if let userDict = json["user"] as? [String: Any], let role = userDict["role"] as? String {
                        onSuccess(role)
                    } else {
                        onSuccess("user")
                    }
                } else {
                    onError(json["message"] as? String ?? "Invalid OTP")
                }
            case .failure(let error):
                onError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Password Reset
    func sendPasswordReset(email: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        request(endpoint: "/auth/forgot-password", body: ["email": email]) { result in
            switch result {
            case .success(let json):
                if let success = json["success"] as? Bool, success {
                    onSuccess()
                } else {
                    onError(json["message"] as? String ?? "Failed to send reset email")
                }
            case .failure(let error):
                onError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Get Current User Data
    func getCurrentUserData(onSuccess: @escaping (User) -> Void, onError: @escaping (String) -> Void) {
        request(endpoint: "/auth/me", method: "GET") { result in
            switch result {
            case .success(let json):
                if let success = json["success"] as? Bool, success,
                   let userDict = json["user"] as? [String: Any] {
                    
                    let id = userDict["id"] as? Int ?? 0
                    let user = User(
                        uid: String(id),
                        firstName: userDict["first_name"] as? String ?? "",
                        lastName: userDict["last_name"] as? String ?? "",
                        email: userDict["email"] as? String ?? "",
                        phone: userDict["phone"] as? String ?? "",
                        role: userDict["role"] as? String ?? "user",
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                    onSuccess(user)
                } else {
                    onError("Failed to fetch user profile")
                }
            case .failure(let error):
                onError(error.localizedDescription)
            }
        }
    }
}
