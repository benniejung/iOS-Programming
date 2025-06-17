//
//  HeaderView.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/13.
//

import Foundation
import UIKit
import SnapKit
import Then

final class MainHeaderView: UIView {
    
    private let titleLabel = UILabel().then {
        let title = "FamilyApp"
         let attributes: [NSAttributedString.Key: Any] = [
             .font: UIFont.boldSystemFont(ofSize: 24),
             .foregroundColor: UIColor(named: "mainBlue") ?? .systemBlue
         ]
         $0.attributedText = NSAttributedString(string: title, attributes: attributes)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        self.addSubview(
            titleLabel
        )
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(15)
        }
    }
}
