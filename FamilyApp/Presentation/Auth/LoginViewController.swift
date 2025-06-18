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

    private let logoImageView = UIImageView().then {
        $0.image = UIImage(named: "main_logo") // Assets에 main_logo 추가되어 있어야 함
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: - Header
    private let logoLabel = UILabel().then {
        $0.text = "PostiFam"
        $0.font = UIFont(name: "Helvetica-Bold", size: 45)
        $0.textColor = .white
        $0.textAlignment = .center
    }

    private let subtitleLabel = UILabel().then {
        $0.text = "하루 한 장, 가족과 함께하는 일상 공유 플랫폼"
        $0.font = .systemFont(ofSize: 15)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    // MARK: - Card Container
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowRadius = 10
    }

    private let emailField = IconTextField(
        iconName: "envelope",
        placeholder: "Enter your email"
    )

    private let passwordField = IconTextField(
        iconName: "key",
        placeholder: "Enter your password",
        isSecure: true
    )

    private let signInButton = UIButton().then {
        $0.setTitle("로그인", for: .normal)
        $0.backgroundColor = UIColor(hex: "#FBB65F")
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 12
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
    }

    private let signUpHintLabel = UILabel().then {
        let text = NSMutableAttributedString(
            string: "계정이 없으신가요? ",
            attributes: [.foregroundColor: UIColor.darkGray]
        )
        text.append(NSAttributedString(
            string: "회원가입",
            attributes: [.foregroundColor: UIColor(hex: "#6D97DE")]
        ))
        $0.attributedText = text
        $0.font = .systemFont(ofSize: 13)
        $0.textAlignment = .center
        $0.isUserInteractionEnabled = true
    }
    
    // 레이블 추가
    private let emailTitleLabel = UILabel().then {
        $0.text = "이메일"
        $0.font = .boldSystemFont(ofSize: 14)
        $0.textColor = .black
    }

    private let passwordTitleLabel = UILabel().then {
        $0.text = "비밀번호"
        $0.font = .boldSystemFont(ofSize: 14)
        $0.textColor = .black
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#FFAE52")
        layout()
        signInButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapSignUp))
        signUpHintLabel.addGestureRecognizer(tap)
    }

    // MARK: - Layout
    private func layout() {
        [logoImageView, logoLabel, subtitleLabel, containerView].forEach { view.addSubview($0) }
            [
                emailTitleLabel, emailField,
                passwordTitleLabel, passwordField,
                signInButton, signUpHintLabel
            ].forEach { containerView.addSubview($0) }

        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)  // 필요 시 크기 조절
        }

        logoLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }

         subtitleLabel.snp.makeConstraints {
             $0.top.equalTo(logoLabel.snp.bottom).offset(8)
             $0.centerX.equalToSuperview()
             $0.leading.trailing.equalToSuperview().inset(24)
         }

         containerView.snp.makeConstraints {
             $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
             $0.leading.trailing.equalToSuperview().inset(24)
             $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-40) // 충분한 높이 확보
         }

         emailTitleLabel.snp.makeConstraints {
             $0.top.equalToSuperview().offset(24)
             $0.leading.equalToSuperview().offset(16)
         }

         emailField.snp.makeConstraints {
             $0.top.equalTo(emailTitleLabel.snp.bottom).offset(8)
             $0.leading.trailing.equalToSuperview().inset(16)
             $0.height.equalTo(48)
         }

         passwordTitleLabel.snp.makeConstraints {
             $0.top.equalTo(emailField.snp.bottom).offset(16)
             $0.leading.equalToSuperview().offset(16)
         }

         passwordField.snp.makeConstraints {
             $0.top.equalTo(passwordTitleLabel.snp.bottom).offset(8)
             $0.leading.trailing.equalToSuperview().inset(16)
             $0.height.equalTo(48)
         }

         signInButton.snp.makeConstraints {
             $0.top.equalTo(passwordField.snp.bottom).offset(24)
             $0.leading.trailing.equalToSuperview().inset(16)
             $0.height.equalTo(48)
         }

         signUpHintLabel.snp.makeConstraints {
             $0.top.equalTo(signInButton.snp.bottom).offset(16)
             $0.bottom.equalToSuperview().inset(24)
             $0.centerX.equalToSuperview()
         }
    }

    // MARK: - Actions
    @objc private func didTapLogin() {
        guard
            let email = emailField.text, !email.isEmpty,
            let password = passwordField.text, !password.isEmpty
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

            Firestore.firestore().collection("users").document(user.uid).getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    UserDefaults.standard.set(user.uid, forKey: "userId")
                    UserDefaults.standard.set(data["name"] as? String ?? "", forKey: "userName")
                    UserDefaults.standard.set(data["familyId"] as? String ?? "", forKey: "familyId")
                    UserDefaults.standard.set(data["role"] as? String ?? "", forKey: "role")

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


final class IconTextField: UIView {
    let iconView = UIImageView()
    let textField = UITextField()

    init(iconName: String, placeholder: String, isSecure: Bool = false) {
        super.init(frame: .zero)

        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = .gray

        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.borderStyle = .none

        let wrapper = UIView()
        wrapper.backgroundColor = .white
        wrapper.layer.cornerRadius = 10
        wrapper.layer.borderColor = UIColor(hex: "#E5E7EB").cgColor
        wrapper.layer.borderWidth = 1.0
        addSubview(wrapper)
        
        wrapper.addSubview(iconView)
        wrapper.addSubview(textField)


        iconView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        textField.snp.makeConstraints {
            $0.leading.equalTo(iconView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(44)
        }

        wrapper.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) { fatalError() }

    var text: String? { textField.text }
}
