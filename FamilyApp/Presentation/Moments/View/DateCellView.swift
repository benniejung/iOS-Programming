//
//  DateCellView.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/13.
//

import Foundation
import UIKit
import SnapKit
import Then

final class DateCell: UICollectionViewCell {
    static let identifier = "DateCell"
     
    private let dayLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textAlignment = .center

    }

    private let weekdayLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .center

    }

    private var gradientLayer: CAGradientLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
          contentView.layer.cornerRadius = 10
          contentView.clipsToBounds = true
          contentView.backgroundColor = UIColor(hex: "#FFAE52") // ✅ 셀 배경색 적용

          contentView.addSubview(dayLabel)
          contentView.addSubview(weekdayLabel)

          dayLabel.snp.makeConstraints {
              $0.top.equalToSuperview().offset(8)
              $0.centerX.equalToSuperview()
          }

          weekdayLabel.snp.makeConstraints {
              $0.top.equalTo(dayLabel.snp.bottom).offset(2)
              $0.centerX.equalToSuperview()
              $0.bottom.equalToSuperview().offset(-8)
          }
      }

    override func prepareForReuse() {
        super.prepareForReuse()
        // 이전에 추가된 그라데이션 제거
        //gradientLayer?.removeFromSuperlayer()
    }

    func configure(with model: DateModel, today: Date) {
        dayLabel.text = model.dayString
        weekdayLabel.text = model.weekdayString

        let calendar = Calendar.current
        let dateOnly = calendar.startOfDay(for: model.date)
        let todayOnly = calendar.startOfDay(for: today)

        if dateOnly == todayOnly {
            // 오늘 날짜 셀은 완전한 흰색
            contentView.backgroundColor = .white
            dayLabel.textColor = .black
            weekdayLabel.textColor = .black
        } else {
            // 나머지 셀은 반투명 흰색
            contentView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            dayLabel.textColor = .white
            weekdayLabel.textColor = .white
        }
    }


    private func applyGradientBackground() {
        gradientLayer?.removeFromSuperlayer() // 중복 방지

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(hex: "#6366F1").cgColor,
            UIColor(hex: "#9333EA").cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = contentView.bounds
        gradient.cornerRadius = 10

        contentView.layer.insertSublayer(gradient, at: 0)
        self.gradientLayer = gradient
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
