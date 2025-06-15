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

final class MomentComposeViewController: UIViewController {
    
    var selectedImage: UIImage? // 전달받을 이미지

    private let imageView = UIImageView()
    private let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "글 작성하기"
        setUI()
    }

    private func setUI() {
        view.addSubview(imageView)
        view.addSubview(textView)
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }

        textView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }

        imageView.contentMode = .scaleAspectFit
        imageView.image = selectedImage // 전달받은 이미지 보여주기
    }
}
