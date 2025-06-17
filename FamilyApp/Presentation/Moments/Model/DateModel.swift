//
//  DateModel.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/13.
//

import Foundation

struct DateModel {
    let date: Date
    
    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}
