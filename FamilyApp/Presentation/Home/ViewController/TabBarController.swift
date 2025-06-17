//
//  TabBarController.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/12.
//

import Foundation
import UIKit
import SnapKit
import Then

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBarAppearance()
        setTabBar()
    }
    
    private func setTabBar() {
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(named: "home")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "home_fill")?.withRenderingMode(.alwaysOriginal))
        
        let momentsVC = MomentsViewController()
        momentsVC.tabBarItem = UITabBarItem(
            title: "Moments",
            image: UIImage(named: "heart")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "heart_fill")?.withRenderingMode(.alwaysOriginal))
  
        let eventsVC = EventsViewController()
        eventsVC.tabBarItem = UITabBarItem(
            title: "Events",
            image: UIImage(named: "calendar")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "calendar_fill")?.withRenderingMode(.alwaysOriginal))

        viewControllers = [homeVC, momentsVC, eventsVC]
        
        
    }
    
    private func setTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground() // blur 제거

        // 배경 색상
        appearance.backgroundColor = .white

        // 상단 테두리
        appearance.shadowColor = UIColor(red: 0.898, green: 0.906, blue: 0.922, alpha: 1) // 연회색
        appearance.shadowImage = UIImage() // 필요 시 추가

        // 그림자 효과 (Layer로 수동 추가해야 함)
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 10
        tabBar.layer.masksToBounds = false

        // 선택된 아이템 텍스트 컬러
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.black
        ]

        // 비선택 텍스트 컬러도 지정 가능
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.lightGray
        ]
        
        // 적용
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }

}
