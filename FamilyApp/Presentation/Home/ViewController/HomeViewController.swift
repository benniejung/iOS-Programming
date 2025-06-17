//
//  HomeViewController.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/12.
//

import Foundation
import UIKit
import SnapKit
import Then

final class HomeViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel().then {
        $0.text = "FamilyApp"
        $0.font = UIFont.boldSystemFont(ofSize: 24)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private let bottomView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 24
        $0.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 205/255, green: 240/255, blue: 153/255, alpha: 1) // 연두색
        setUI()
    }
    
    private func setUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints {
             $0.edges.equalToSuperview()
         }
        

        
        // 상단 Title
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
        
        // 하단 White Card
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(50)
            $0.leading.trailing.equalToSuperview()
            //$0.height.equalTo(400)
            $0.bottom.equalToSuperview().offset(-40)
         }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.bottom).offset(40)
        }
       
  
    }
}
