//
//  SignUpView.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/17.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

final class SignUpViewController: UIViewController {

    // MARK: - UI Components
    private let emailTextField = UITextField().then {
        $0.placeholder = "이메일"
        $0.borderStyle = .roundedRect
        $0.keyboardType = .emailAddress
        $0.autocapitalizationType = .none
    }

    private let passwordTextField = UITextField().then {
        $0.placeholder = "비밀번호 (6자 이상)"
        $0.borderStyle = .roundedRect
        $0.isSecureTextEntry = true
    }

    private let nameTextField = UITextField().then {
        $0.placeholder = "이름 또는 호칭 (예: 언니, 아빠)"
        $0.borderStyle = .roundedRect
    }

    private let signUpButton = UIButton(type: .system).then {
        $0.setTitle("회원가입", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
        $0.backgroundColor = .systemBlue
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 8
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layout()
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }

    // MARK: - Layout
    private func layout() {
        [emailTextField, passwordTextField, nameTextField, signUpButton].forEach {
            view.addSubview($0)
        }

        emailTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        nameTextField.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        signUpButton.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
    }

    // MARK: - Action
    @objc private func didTapSignUp() {
        guard
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, password.count >= 6,
            let name = nameTextField.text, !name.isEmpty
        else {
            showAlert(message: "모든 항목을 입력해주세요.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(message: "회원가입 실패: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user else { return }

            // Firestore users 컬렉션에 사용자 정보 저장
            let data: [String: Any] = [
                "name": name,
                "email": email,
                "familyId": "defaultFamily" // ← 추후 가족 선택 UI와 연결
            ]

            Firestore.firestore().collection("users").document(user.uid).setData(data) { error in
                if let error = error {
                    self.showAlert(message: "사용자 정보 저장 실패: \(error.localizedDescription)")
                } else {
                    self.showAlert(message: "회원가입 성공!", completion: {
                        self.dismiss(animated: true)
                    })
                }
            }
        }
    }

    // MARK: - Helper
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
