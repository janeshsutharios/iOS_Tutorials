//
//  AuthService.swift
//  FoodApp
//
//  Created by Janesh Suthar on 05/08/25.
//

import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class AuthService: AuthServiceProtocol {
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Simulate network request
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            if email == "test@gmail.com" && password == "123" {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])))
            }
        }
    }
}
