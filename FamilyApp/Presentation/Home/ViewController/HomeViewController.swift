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
import FirebaseFirestore

struct FamilyMember {
    let name: String
    let role: String
}

//struct Schedule {
//    let userName: String
//    let task: String
//    let date: Date
//}

final class HomeViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerView = UIView().then {
        $0.backgroundColor = UIColor(hex: "#FFAE52")
    }

    private let titleLabel = UILabel().then {
        $0.text = "PostiFam"
        $0.font = UIFont.boldSystemFont(ofSize: 30)
        $0.textColor = .white
        $0.textAlignment = .center
    }

    private let helloLabel = UILabel().then {
        $0.text = "Hello!\n오늘 어떤 하루를 보냈나요?"
        $0.numberOfLines = 2
        $0.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        $0.textColor = .white
    }

    private let reportButton = UIButton().then {
        $0.setTitle("→ 가족에게 생존신고하기", for: .normal)
         $0.setTitleColor(.black, for: .normal)
         $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
         $0.backgroundColor = UIColor(hex: "#FFDCA6")
         $0.layer.cornerRadius = 20
         $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20) // 패딩
    }

    private let bottomView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 24
        $0.layer.masksToBounds = true
    }

    private let myFamilyLabel = UILabel().then {
        $0.text = "My Family"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }

    private let familyStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .top
        $0.distribution = .fillEqually   // ✅ 셀 개수에 상관없이 균등 분배
    }

    private let todayLabel = UILabel().then {
        $0.text = "Today"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    private let emptyFamilyLabel = UILabel().then {
        $0.text = "가족을 초대해서 서비스를 시작해요!"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .darkGray
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.isHidden = true
    }

    private let inviteButton = UIButton().then {
        $0.setTitle("가족 초대하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(hex: "#FFAE52")
        $0.layer.cornerRadius = 20
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
        $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        $0.isHidden = true
    }

    private let todayStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        layout()
        fetchFamilyMembers()
        fetchTodaySchedules()
        inviteButton.addTarget(self, action: #selector(inviteFamily), for: .touchUpInside)

    }

    private func layout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        bottomView.addSubview(emptyFamilyLabel)
        bottomView.addSubview(inviteButton)

        emptyFamilyLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(60)
            $0.leading.trailing.equalToSuperview().inset(32)
        }

        inviteButton.snp.makeConstraints {
            $0.top.equalTo(emptyFamilyLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // MARK: - Header
        contentView.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.equalTo(view.snp.top) // 상태바 포함
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }

        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8) 
            $0.centerX.equalToSuperview()
        }

        headerView.addSubview(helloLabel)
        helloLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
        }

        headerView.addSubview(reportButton)
        reportButton.snp.makeConstraints {
            $0.top.equalTo(helloLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.lessThanOrEqualToSuperview().offset(-24)
            $0.height.equalTo(44)
        }

        // MARK: - Bottom View
        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(-24)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        bottomView.addSubview(myFamilyLabel)
        myFamilyLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.equalToSuperview().offset(20)
        }

        bottomView.addSubview(familyStack)
        familyStack.snp.makeConstraints {
            $0.top.equalTo(myFamilyLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(100)
        }

        bottomView.addSubview(todayLabel)
        todayLabel.snp.makeConstraints {
            $0.top.equalTo(familyStack.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
        }

        bottomView.addSubview(todayStack)
        todayStack.snp.makeConstraints {
            $0.top.equalTo(todayLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-40)
        }
    }

    private func fetchFamilyMembers() {
        Firestore.firestore().collection("families").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            DispatchQueue.main.async {
                if docs.isEmpty {
                    // ❌ 가족 없음: 관련 뷰 숨기고 초대 버튼만 표시
                    self.helloLabel.isHidden = true
                     self.reportButton.isHidden = true
                     self.myFamilyLabel.isHidden = true
                     self.familyStack.isHidden = true
                     self.todayLabel.isHidden = true
                     self.todayStack.isHidden = true

                     self.emptyFamilyLabel.isHidden = false
                     self.inviteButton.isHidden = false

                    self.reportButton.setTitle("→ 가족 초대하기", for: .normal)
                    self.reportButton.removeTarget(nil, action: nil, for: .allEvents)
                    self.reportButton.addTarget(self, action: #selector(self.inviteFamily), for: .touchUpInside)

                } else {
                    self.helloLabel.isHidden = false
                    self.reportButton.isHidden = true  // 항상 숨김 처리
                    self.myFamilyLabel.isHidden = false
                    self.familyStack.isHidden = false
                    self.todayLabel.isHidden = false
                    self.todayStack.isHidden = false

                    self.emptyFamilyLabel.isHidden = true
                    self.inviteButton.isHidden = true

                    for doc in docs {
                        let data = doc.data()
                        guard let name = data["name"] as? String,
                              let role = data["role"] as? String else { continue }

                        let view = self.createFamilyItem(name: name, role: role)
                        self.familyStack.addArrangedSubview(view)
                    }

                    self.fetchTodaySchedules()
                }
            }
        }
    }


    @objc private func inviteFamily() {
        let inviteText = "우리 가족 앱에 초대할게! 아래 링크를 눌러 함께 시작해봐 😊\n\nhttps://example.com/invite"
        let activityVC = UIActivityViewController(activityItems: [inviteText], applicationActivities: nil)

        // iPad 대응 (필수는 아님)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = self.reportButton
            popover.sourceRect = self.reportButton.bounds
        }

        present(activityVC, animated: true)
    }



    private func fetchTodaySchedules() {
        let calendar = Calendar.current
        let now = Date()

        Firestore.firestore().collection("schedules").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            for doc in docs {
                let data = doc.data()
                guard let userName = data["userName"] as? String,
                      let task = data["task"] as? String,
                      let timestamp = data["date"] as? Timestamp else { continue }

                let taskDate = timestamp.dateValue()
                if calendar.isDate(taskDate, inSameDayAs: now) {
                    let view = self.createScheduleItem(userName: userName, task: task, date: taskDate)
                    self.todayStack.addArrangedSubview(view)
                }
            }
        }
    }

    private func createFamilyItem(name: String, role: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(hex: "#FFF1E0")
        container.layer.cornerRadius = 12

        let imageView = UIImageView().then {
            $0.image = UIImage(named: imageName(for: role))
            $0.contentMode = .scaleAspectFit
        }

        let nameLabel = UILabel().then {
            $0.text = name
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 14)
        }

        container.addSubview(imageView)
        container.addSubview(nameLabel)
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(50) // ✅ 명시적 고정
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }

//        container.snp.makeConstraints {
//            $0.width.equalTo(80)
//        }

        return container
    }

    private func createScheduleItem(userName: String, task: String, date: Date) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(hex: "#FFDCA6").cgColor

        let iconView = UIImageView().then {
            $0.image = UIImage(named: "calendar_fill") // 🔁 아이콘 변경 (예: 달력)
            $0.contentMode = .scaleAspectFit
        }

        let nameLabel = UILabel().then {
            $0.text = userName
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = .gray
        }

        let taskLabel = UILabel().then {
            $0.text = task
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = .black
        }

        let vStack = UIStackView(arrangedSubviews: [nameLabel, taskLabel])
        vStack.axis = .vertical
        vStack.spacing = 2
        vStack.alignment = .leading

        container.addSubview(iconView)
        container.addSubview(vStack)

        iconView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(32)
        }

        vStack.snp.makeConstraints {
            $0.leading.equalTo(iconView.snp.trailing).offset(12)
            $0.top.bottom.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().offset(-12)
        }

        return container
    }

    private func imageName(for role: String) -> String {
        switch role.lowercased() {
        case "dad": return "icon_dad"
        case "mom": return "icon_mom"
        case "child": return "icon_child"
        default: return "icon_default"
        }
    }
}
