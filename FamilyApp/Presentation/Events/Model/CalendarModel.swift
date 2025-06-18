//
//  CalendarModel.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/18.
//

import Foundation
import FirebaseFirestore

// MARK: - Model
struct CalendarDate {
    let date: Date
    let isCurrentMonth: Bool
    var schedules: [Schedule]
}

struct Schedule {
    let userName: String
    let task: String
    let date: Date
}

final class CalendarModel {
    private let calendar = Calendar.current
    private let db = Firestore.firestore()
    
    func dates(for month: Date, completion: @escaping ([CalendarDate]) -> Void) {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end.addingTimeInterval(-1)) else {
            completion([])
            return
        }
        
        let days = stride(from: monthInterval.start, to: monthInterval.end, by: 60 * 60 * 24).map {
            CalendarDate(
                date: $0,
                isCurrentMonth: true,
                schedules: []
            )
        }
        
        fetchSchedules(for: days) { updatedDates in
            completion(updatedDates)
        }
    }
    
    private func fetchSchedules(for days: [CalendarDate], completion: @escaping ([CalendarDate]) -> Void) {
        db.collection("schedules").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("❌ 일정 데이터 가져오기 실패: \(error?.localizedDescription ?? "알 수 없음")")
                completion(days)
                return
            }
            
            var updatedDates = days
            
            for doc in documents {
                let data = doc.data()
                guard let userName = data["userName"] as? String,
                      let task = data["task"] as? String,
                      let timestamp = data["date"] as? Timestamp else {
                    continue
                }
                
                let taskDate = timestamp.dateValue()
                
                if let index = updatedDates.firstIndex(where: { self.calendar.isDate($0.date, inSameDayAs: taskDate) }) {
                    let schedule = Schedule(userName: userName, task: task, date: taskDate)
                    updatedDates[index].schedules.append(schedule)
                }
            }
            
            completion(updatedDates)
        }
    }
}
