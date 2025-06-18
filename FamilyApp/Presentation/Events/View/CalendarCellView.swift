//
//  CalendarCellView.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/18.
//

import Foundation
import UIKit

final class CalendarDateCellView: UICollectionViewCell {
    let dayLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(dayLabel)
        dayLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.layer.cornerRadius = 8
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with date: CalendarDate, isToday: Bool, isSelectedDate: Bool) {
        let day = Calendar.current.component(.day, from: date.date)
        dayLabel.text = "\(day)"

        // 글자 색상
        dayLabel.textColor = date.isCurrentMonth ? .black : .lightGray

        // 배경 설정
        if isSelectedDate {
            contentView.backgroundColor = UIColor(hex: "#FFAE52") // 동그라미 배경
            dayLabel.textColor = .white
        } else if isToday {
            contentView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.3)
        } else {
            contentView.backgroundColor = .clear
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // ✅ 중복 설정 방지를 위해 조건 체크 (선택)
        if contentView.layer.cornerRadius != contentView.frame.width / 2 {
            contentView.layer.cornerRadius = contentView.frame.width / 2
            contentView.layer.masksToBounds = true // 꼭 추가
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        // ✅ 배경 색상, 선택 상태, 텍스트 컬러 등 초기화
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        dayLabel.textColor = .black
        // 만약 selected 색을 따로 넣었다면 초기화도 같이
    }
}
