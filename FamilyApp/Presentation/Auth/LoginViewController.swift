//
//  LoginViewController.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/17.
//

import Foundation
import UIKit
import FirebaseAuth
import SnapKit
import Then
import FirebaseFirestore

final class LoginViewController: UIViewController {

    // MARK: - UI Components
    private let emailTextField = UITextField().then {
        $0.placeholder = "이메일"
        $0.borderStyle = .roundedRect
        $0.keyboardType = .emailAddress
        $0.autocapitalizationType = .none
    }

    private let passwordTextField = UITextField().then {
        $0.placeholder = "비밀번호"
        $0.borderStyle = .roundedRect
        $0.isSecureTextEntry = true
    }

    private let loginButton = UIButton(type: .system).then {
        $0.setTitle("로그인", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 8
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
    }

    private let signUpLabel = UILabel().then {
        $0.text = "계정이 없으신가요? 회원가입"
        $0.textColor = .systemGray
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 13)
        $0.isUserInteractionEnabled = true
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layout()
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapSignUp))
        signUpLabel.addGestureRecognizer(tap)
    }

    // MARK: - Layout
    private func layout() {
        [emailTextField, passwordTextField, loginButton, signUpLabel].forEach {
            view.addSubview($0)
        }

        emailTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(100)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        loginButton.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(50)
        }

        signUpLabel.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }
    }

    // MARK: - Actions
    @objc private func didTapLogin() {
        guard
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else {
            showAlert(message: "이메일과 비밀번호를 입력해주세요.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
             guard let self = self else { return }

             if let error = error {
                 self.showAlert(message: "로그인 실패: \(error.localizedDescription)")
                 return
             }

             guard let user = result?.user else { return }

             // 🔸 Firestore에서 사용자 추가 정보 조회
             Firestore.firestore().collection("users").document(user.uid).getDocument { snapshot, error in
                 if let data = snapshot?.data() {
                     // 🔹 UserDefaults에 저장
                     UserDefaults.standard.set(user.uid, forKey: "userId")
                     UserDefaults.standard.set(data["name"] as? String ?? "", forKey: "userName")
                     UserDefaults.standard.set(data["familyId"] as? String ?? "", forKey: "familyId")

                     print("✅ 사용자 정보 저장 완료")

                     self.switchToMainApp()
                 } else {
                     self.showAlert(message: "사용자 정보 불러오기 실패")
                 }
             }
         }
    }

    @objc private func didTapSignUp() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func switchToMainApp() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }

        let tabBar = TabBarController()
        window.rootViewController = UINavigationController(rootViewController: tabBar)
        window.makeKeyAndVisible()
    }
}
