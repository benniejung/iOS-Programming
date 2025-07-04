//
//  SignUp.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/17.
//

import Foundation
import FirebaseAuth

func signUp(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
    Auth.auth().createUser(withEmail: email, password: password) { result, error in
        if let error = error {
            completion(.failure(error))
        } else if let result = result {
            completion(.success(result))
        }
    }
}
