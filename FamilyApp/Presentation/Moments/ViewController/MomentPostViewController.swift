//
//  MomentComposeViewController.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/15.
//

import Foundation
import UIKit
import SnapKit
import Then
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

final class MomentPostViewController: UIViewController {
    
    var selectedImage: UIImage? // 전달받을 이미지

    // 구성 요소
    private let imageView = UIImageView()
    private let contentField = UITextField()
    
    private let imageTextLabel = UILabel().then {
        $0.text = "사진"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .darkGray
    }

    private let contentTextLabel = UILabel().then {
        $0.text = "내용"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .darkGray
    }
    
    private let uploadButton = UIButton().then {
        $0.setTitle("업로드하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(hex: "#FFAE52")
        $0.layer.cornerRadius = 8
    }

    // 초기 로드 메서드
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "글 작성하기"
        setUI()
    }

    private func setUI() {
        [imageTextLabel, imageView, contentTextLabel, contentField, uploadButton].forEach {
                view.addSubview($0)
        }
        
        imageTextLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().inset(20)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        
        contentTextLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(20)
        }

        contentField.snp.makeConstraints {
              $0.top.equalTo(contentTextLabel.snp.bottom).offset(8)
              $0.leading.trailing.equalToSuperview().inset(20)
              $0.height.equalTo(44)
          }

        uploadButton.snp.makeConstraints {
            $0.top.equalTo(contentField.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }

        uploadButton.addTarget(self, action: #selector(uploadMoment), for: .touchUpInside)
        

        imageView.contentMode = .scaleAspectFit
        imageView.image = selectedImage // 전달받은 이미지 보여주기
        
        contentField.placeholder = "글을 작성해주세요"
        contentField.borderStyle = .roundedRect
    }
    
    // 파이어베이스에 저장
    @objc private func uploadMoment() {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8),
              let content = contentField.text, !content.isEmpty else {
            print("❗️이미지 또는 내용이 없음")
            print("userName:", UserDefaults.standard.string(forKey: "userName") ?? "nil")
            print("familyId:", UserDefaults.standard.string(forKey: "familyId") ?? "nil")
            print("role:", UserDefaults.standard.string(forKey: "role") ?? "nil")

            return
        }

        // 🔒 사용자 정보 불러오기
        guard let userId = Auth.auth().currentUser?.uid,
              let userName = UserDefaults.standard.string(forKey: "userName"),
              let familyId = UserDefaults.standard.string(forKey: "familyId"),
              let role = UserDefaults.standard.string(forKey: "role") else {
            print("❌ 사용자 정보가 없습니다")
            return
        }

        let imageName = UUID().uuidString
        let imageRef = Storage.storage().reference().child("moments/\(imageName).jpg")

        imageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ 이미지 업로드 실패: \(error.localizedDescription)")
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ 다운로드 URL 가져오기 실패: \(error.localizedDescription)")
                    return
                }

                guard let imageURL = url?.absoluteString else {
                    print("❌ 다운로드 URL이 nil입니다.")
                    return
                }

                // ✅ MomentsModel에 모든 정보 포함해서 생성
                let moment = MomentsModel(
                    imageURL: imageURL,
                    content: content,
                    timestamp: Date(),
                    userId: userId,
                    userName: userName,
                    familyId: familyId,
                    role: role
                )

                let data = moment.toDictionary()

                Firestore.firestore().collection("moments").addDocument(data: data) { error in
                    if let error = error {
                        print("❌ 파이어스토어 저장 실패: \(error.localizedDescription)")
                    } else {
                        print("✅ 성공적으로 업로드됨!")
                        self.navigationController?.popViewController(animated: true)
                        NotificationCenter.default.post(name: .momentDidUpload, object: nil)
                    }
                }
            }
        }
    
    }

}
