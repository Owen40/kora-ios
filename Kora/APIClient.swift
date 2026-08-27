//
//  APIClient.swift
//  Kora
//
//  Created by mac on 8/16/26.
//
import Foundation

class APIClient {
    static let shared = APIClient()
    private let baseURL = "https://kora.bmsdyna.live/api"
    
    private init() {}
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "jwt_token")
    }
    
    func request(endpoint: String, method: String = "GET", body: [String: Any]? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
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
}
