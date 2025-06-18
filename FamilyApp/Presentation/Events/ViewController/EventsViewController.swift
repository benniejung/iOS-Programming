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
            $0.top.equalTo(yearMonthLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(20)
        }
    }

    private let titleLabel = UILabel().then {
        $0.text = "Calendar"
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // ✅ 먼저 요일 헤더를 추가
         //setupWeekDaysHeader()

         // ✅ 그다음 레이아웃 설정
         setupLayout()
         setupAction()
         reloadCalendar()

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
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
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
    }


    private func setupAction() {
        prevButton.addTarget(self, action: #selector(didTapPrev), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
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
        calendarManager.dates(for: currentDate) { [weak self] dates in
            self?.calendarDates = dates
            DispatchQueue.main.async {
                self?.calendarCollectionView.reloadData()
            }

            if let current = self?.currentDate {
                self?.selectedDate = current // ✅ 초기 선택 날짜 설정
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
        container.backgroundColor = UIColor(hex: "#FAF7F2") // 전체 배경

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

        return container
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
