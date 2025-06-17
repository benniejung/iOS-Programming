//
//  Login.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/17.
//

import Foundation
import FirebaseAuth

func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
    Auth.auth().signIn(withEmail: email, password: password) { result, error in
        if let error = error {
            completion(.failure(error))
        } else if let user = result?.user {
            completion(.success(user))
        }
    }
}

func logout() {
    do {
        try Auth.auth().signOut()
        print("✅ 로그아웃 완료")
    } catch {
        print("❌ 로그아웃 실패: \(error.localizedDescription)")
    }
}
