//
//  EventsViewController.swift
//  FamilyApp
//
//  Created by yebin on 2025/06/13.
//

import Foundation
import UIKit
import SnapKit
import Then
import FirebaseFirestore

final class EventsViewController: UIViewController {

    private let calendarManager = CalendarModel()
    private var currentDate = Date()
    private var calendarDates: [CalendarDate] = []
    private var selectedDate: Date?


    private let weekDaysStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .center
    }

    private func setupWeekDaysHeader() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        let weekSymbols = formatter.shortStandaloneWeekdaySymbols // ["일", "월", "화", ...]

        weekSymbols?.forEach { day in
            let label = UILabel().then {
                $0.text = day
                $0.textAlignment = .center
                $0.font = .systemFont(ofSize: 14, weight: .medium)
                $0.textColor = .darkGray
            }
            weekDaysStackView.addArrangedSubview(label)
        }

        view.addSubview(weekDaysStackView)
        weekDaysStackView.snp.makeConstraints {
            $0.top.equalTo(yearMonthLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(20)
        }
    }

    private let titleLabel = UILabel().then {
        $0.text = "Events"
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textColor = .white
    }

    private let headerView = UIView().then {
        $0.backgroundColor = UIColor(hex: "#FDAF3F")
    }

    private let yearMonthLabel = UILabel().then {
        $0.text = "2025년 05월"
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .black
    }

    private lazy var calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createCalendarLayout()).then {
        $0.backgroundColor = .clear
        $0.dataSource = self
        $0.delegate = self
        $0.register(CalendarDateCellView.self, forCellWithReuseIdentifier: "CalendarDateCell")
    }

    private let scheduleBox = UIView().then {
        $0.backgroundColor = UIColor(hex: "#F7F1E8")
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }

    private let scheduleLabel = UILabel().then {
        $0.text = "오늘 날짜 스케줄"
        $0.font = .boldSystemFont(ofSize: 14)
        $0.textColor = .black
    }

    private let scheduleStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .equalSpacing
    }

    private let prevButton = UIButton().then {
        $0.setTitle("<", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }

    private let nextButton = UIButton().then {
        $0.setTitle(">", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    private let addScheduleButton = UIButton().then {
        $0.setTitle("일정 추가하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(hex: "#FDAF3F")
        $0.layer.cornerRadius = 8
        $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // ✅ 먼저 요일 헤더를 추가
         //setupWeekDaysHeader()

         // ✅ 그다음 레이아웃 설정
         setupLayout()
         setupAction()
         reloadCalendar()
        updateYearMonthLabel()

    }

    private func createCalendarLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 4
        let width = (UIScreen.main.bounds.width - 40) / 7
        layout.itemSize = CGSize(width: width, height: 40)
        return layout
    }

    private func setupLayout() {
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(yearMonthLabel)
        headerView.addSubview(prevButton)
        headerView.addSubview(nextButton)

        // ✅ 요일 헤더 추가 및 구성
        view.addSubview(weekDaysStackView)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        let weekSymbols = formatter.shortStandaloneWeekdaySymbols // ["일", "월", ...]

        weekSymbols?.forEach { day in
            let label = UILabel().then {
                $0.text = day
                $0.textAlignment = .center
                $0.font = .systemFont(ofSize: 14, weight: .medium)
                $0.textColor = .darkGray
            }
            weekDaysStackView.addArrangedSubview(label)
        }

        view.addSubview(calendarCollectionView)
        view.addSubview(scheduleBox)
        scheduleBox.addSubview(scheduleLabel)
        scheduleBox.addSubview(scheduleStack)

        // Constraints
        headerView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(140)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(2)
            $0.leading.equalToSuperview().offset(16)
        }

        yearMonthLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(35)
            $0.centerX.equalToSuperview()
        }

        prevButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(16)
        }

        nextButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.trailing.equalToSuperview().offset(-16)
        }

        weekDaysStackView.snp.makeConstraints {
            $0.top.equalTo(prevButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(20)
        }


        calendarCollectionView.snp.makeConstraints {
            $0.top.equalTo(weekDaysStackView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(240)
        }

        scheduleBox.snp.makeConstraints {
            $0.top.equalTo(calendarCollectionView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(12)
            //$0.bottom.equalToSuperview().inset(20)
        }

        scheduleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
        }

        scheduleStack.snp.makeConstraints {
            $0.top.equalTo(scheduleLabel.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
        }
        
        view.addSubview(addScheduleButton)
        addScheduleButton.snp.makeConstraints {
            $0.top.equalTo(scheduleBox.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(40)
        }
    }
    
    private func updateYearMonthLabel() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월"
        yearMonthLabel.text = formatter.string(from: currentDate)
    }

    private func setupAction() {
        prevButton.addTarget(self, action: #selector(didTapPrev), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        addScheduleButton.addTarget(self, action: #selector(addSchedule), for: .touchUpInside)

    }

    @objc private func didTapPrev() {
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
        reloadCalendar()
    }

    @objc private func didTapNext() {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
        reloadCalendar()
    }

    private func reloadCalendar() {
        updateYearMonthLabel()
        calendarManager.dates(for: currentDate) { [weak self] dates in
                self?.calendarDates = dates
                DispatchQueue.main.async {
                    self?.calendarCollectionView.reloadData()
                }

                if let current = self?.currentDate {
                    self?.selectedDate = current
                    self?.updateSchedule(for: current)
                }
            }
    }

    private func updateSchedule(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 EEEE"
        scheduleLabel.text = formatter.string(from: date)

        scheduleStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if let matched = calendarDates.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            for schedule in matched.schedules {
                let view = createScheduleView(userName: schedule.userName, task: schedule.task)
                scheduleStack.addArrangedSubview(view)
            }
        }
    }

    
    private func createScheduleView(userName: String, task: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(hex: "#FAF7F2")

        // 👉 Firestore 문서 찾기 위해 필드 저장
        container.accessibilityLabel = userName + "|" + task

        let colorBar = UIView().then {
            $0.backgroundColor = UIColor(hex: "#FFE4B8")
            $0.layer.cornerRadius = 2
        }

        let nameLabel = UILabel().then {
            $0.text = userName
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textColor = .black
        }

        let taskLabel = UILabel().then {
            $0.text = task
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .black
        }

        let textStack = UIStackView(arrangedSubviews: [nameLabel, taskLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        container.addSubview(colorBar)
        container.addSubview(textStack)

        colorBar.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.width.equalTo(4)
            $0.top.bottom.equalToSuperview().inset(12)
        }

        textStack.snp.makeConstraints {
            $0.leading.equalTo(colorBar.snp.trailing).offset(12)
            $0.top.trailing.bottom.equalToSuperview().inset(12)
        }

        // 👉 탭 제스처 추가
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapSchedule(_:)))
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(tap)

        return container
    }

    
    @objc private func addSchedule() {
        let alert = UIAlertController(title: "일정 추가", message: "추가할 일정을 입력하세요", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "예: 병원 예약, 가족 모임"
        }

        let addAction = UIAlertAction(title: "추가", style: .default) { _ in
            guard let taskText = alert.textFields?.first?.text, !taskText.isEmpty else { return }
            guard let userName = UserDefaults.standard.string(forKey: "userName") else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: self.selectedDate ?? Date())


            let data: [String: Any] = [
                "userName": userName,
                "task": taskText,
                "date": Timestamp(date: self.selectedDate ?? Date()),
                "dateString": dateString
            ]

            Firestore.firestore().collection("schedules").addDocument(data: data) { error in
                if let error = error {
                    print("❌ 일정 추가 실패: \(error.localizedDescription)")
                } else {
                    print("✅ 일정 추가 성공")
                    self.updateSchedule(for: self.selectedDate ?? Date())
                    self.reloadCalendar()
                }
            }
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alert.addAction(addAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true)
    }
    
    @objc private func didTapSchedule(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view,
              let label = view.accessibilityLabel,
              let selectedDate = selectedDate else { return }

        let parts = label.components(separatedBy: "|")
        guard parts.count == 2 else { return }
        let userName = parts[0]
        let task = parts[1]

        let alert = UIAlertController(title: "일정 관리", message: "\"\(task)\" 일정", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "수정", style: .default, handler: { _ in
            self.showEditAlert(originalTask: task, userName: userName, date: selectedDate)
        }))

        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.deleteSchedule(task: task, userName: userName, date: selectedDate)
        }))

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))

        present(alert, animated: true)
    }
    private func showEditAlert(originalTask: String, userName: String, date: Date) {
        let formatter = DateFormatter()
          formatter.dateFormat = "yyyy-MM-dd"
          let dateString = formatter.string(from: date) // 🔧 추가

        let alert = UIAlertController(title: "일정 수정", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.text = originalTask }

        alert.addAction(UIAlertAction(title: "저장", style: .default, handler: { _ in
            guard let newTask = alert.textFields?.first?.text, !newTask.isEmpty else { return }

            let db = Firestore.firestore()
            db.collection("schedules")
                .whereField("userName", isEqualTo: userName)
                .whereField("task", isEqualTo: originalTask)
                .whereField("dateString", isEqualTo: dateString)
                .getDocuments { snapshot, error in
                    if let doc = snapshot?.documents.first {
                        doc.reference.updateData(["task": newTask]) { err in
                            if err == nil {
                                self.reloadCalendar()
                            }
                        }
                    }
                }
        }))

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    private func deleteSchedule(task: String, userName: String, date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        let db = Firestore.firestore()
        db.collection("schedules")
            .whereField("userName", isEqualTo: userName)
            .whereField("task", isEqualTo: task)
            .whereField("dateString", isEqualTo: dateString)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ 쿼리 에러: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("❗️삭제할 문서를 찾지 못함 — 조건 확인 필요")
                    print("조건: userName=\(userName), task=\(task), dateString=\(dateString)")
                    return
                }

                // 🔥 첫 문서 삭제
                let doc = documents.first
                doc?.reference.delete { err in
                    if let err = err {
                        print("❌ 삭제 실패: \(err.localizedDescription)")
                    } else {
                        print("✅ 일정 삭제 성공")
                        self.updateSchedule(for: self.selectedDate ?? Date())
                        self.reloadCalendar()
                    }
                }
            }
    }





}

extension EventsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarDates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDateCell", for: indexPath) as! CalendarDateCellView
        let date = calendarDates[indexPath.item]
        let isToday = Calendar.current.isDateInToday(date.date)
        let isSelected = Calendar.current.isDate(date.date, inSameDayAs: selectedDate ?? Date())
        cell.configure(with: date, isToday: isToday, isSelectedDate: isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDate = calendarDates[indexPath.item].date
        if let selectedDate = selectedDate {
            updateSchedule(for: selectedDate)
        }
        collectionView.reloadData()
   }

}
