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

    // MARK: - Title Label
    private let titleLabel = UILabel().then {
        $0.text = "회원가입"
        $0.font = .boldSystemFont(ofSize: 28)
        $0.textAlignment = .center
        $0.textColor = .black
    }

    // MARK: - Field Labels
    private let emailTitleLabel = UILabel().then {
        $0.text = "이메일"
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }

    private let passwordTitleLabel = UILabel().then {
        $0.text = "비밀번호 (6자 이상)"
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }

    private let nameTitleLabel = UILabel().then {
        $0.text = "이름 또는 호칭"
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }

    // MARK: - Input Fields
    private let emailTextField = UITextField().then {
        $0.placeholder = "example@email.com"
        $0.borderStyle = .roundedRect
        $0.keyboardType = .emailAddress
        $0.autocapitalizationType = .none
    }

    private let passwordTextField = UITextField().then {
        $0.placeholder = "비밀번호 입력"
        $0.borderStyle = .roundedRect
        $0.isSecureTextEntry = true
    }

    private let nameTextField = UITextField().then {
        $0.borderStyle = .roundedRect
    }

    private let signUpButton = UIButton(type: .system).then {
        $0.setTitle("회원가입", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
        $0.backgroundColor = UIColor(hex: "#FFAE52")
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 8
    }
    
    private let roleTitleLabel = UILabel().then {
        $0.text = "역할"
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }

    private let roleSegmentedControl = UISegmentedControl(items: ["부", "모", "자녀"]).then {
        $0.selectedSegmentIndex = 0 // 기본값 "모"
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
        [
            titleLabel,
            emailTitleLabel, emailTextField,
            passwordTitleLabel, passwordTextField,
            nameTitleLabel, nameTextField,
            roleTitleLabel, roleSegmentedControl,
            signUpButton
        ].forEach { view.addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
        }

        emailTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        }

        emailTextField.snp.makeConstraints {
            $0.top.equalTo(emailTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }

        passwordTitleLabel.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }

        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }

        nameTitleLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }

        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }

//        signUpButton.snp.makeConstraints {
//            $0.top.equalTo(nameTextField.snp.bottom).offset(32)
//            $0.leading.trailing.equalToSuperview().inset(20)
//            $0.height.equalTo(48)
//        }
        
        roleTitleLabel.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }

        roleSegmentedControl.snp.makeConstraints {
            $0.top.equalTo(roleTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(32)
        }

        signUpButton.snp.makeConstraints {
            $0.top.equalTo(roleSegmentedControl.snp.bottom).offset(32)
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
        let roles = ["부", "모", "자녀"]
        let selectedRole = roles[roleSegmentedControl.selectedSegmentIndex]
       
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(message: "회원가입 실패: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user else { return }

            let data: [String: Any] = [
                "name": name,
                "email": email,
                "familyId": "defaultFamily",
                "role": selectedRole
            ]

            Firestore.firestore().collection("users").document(user.uid).setData(data) { error in
                if let error = error {
                    self.showAlert(message: "사용자 정보 저장 실패: \(error.localizedDescription)")
                } else {
                    self.showAlert(message: "회원가입 성공!", completion: {
                        if let nav = self.navigationController {
                            nav.popViewController(animated: true) // push로 왔을 경우
                        } else {
                            self.dismiss(animated: true) // present로 왔을 경우
                        }
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
