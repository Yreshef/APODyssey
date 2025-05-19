//
//  CalendarPickerController.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import UIKit

final class CalendarPickerViewController: UIViewController {

    // MARK: - Properties
    private let calendarView = UICalendarView()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let doneButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

    var onDateSelectionComplete: (([DateComponents]) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setup()
        configureCalendar()
    }

    // MARK: - Setup Methods

    private func setup() {
        setupHeaderView()
        setupCalendarView()
    }

    private func setupHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .systemBackground
        view.addSubview(headerView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Select Dates"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)

        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(
            self, action: #selector(doneButtonTapped), for: .touchUpInside)
        headerView.addSubview(doneButton)

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(
            self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        headerView.addSubview(cancelButton)

        // Layout constraints for header view
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 35),

            titleLabel.centerXAnchor.constraint(
                equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(
                equalTo: headerView.centerYAnchor),

            cancelButton.leadingAnchor.constraint(
                equalTo: headerView.leadingAnchor, constant: 16),
            cancelButton.centerYAnchor.constraint(
                equalTo: headerView.centerYAnchor),

            doneButton.trailingAnchor.constraint(
                equalTo: headerView.trailingAnchor, constant: -16),
            doneButton.centerYAnchor.constraint(
                equalTo: headerView.centerYAnchor),
        ])
    }

    private func setupCalendarView() {
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarView)

        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(
                equalTo: headerView.bottomAnchor, constant: 12),
            calendarView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16),
            calendarView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    private func configureCalendar() {
        calendarView.calendar = Calendar(identifier: .gregorian)
        calendarView.locale = .autoupdatingCurrent
        calendarView.timeZone = .current
        calendarView.fontDesign = .rounded
        calendarView.tintColor = .systemMint

        // Disable dates after today
        calendarView.availableDateRange = DateInterval(
            start: .distantPast, end: Date())

        let dateSelection = UICalendarSelectionMultiDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
    }

    // MARK: - Actions
    @objc private func doneButtonTapped() {

        guard
            let selection = calendarView.selectionBehavior
                as? UICalendarSelectionMultiDate
        else {
            return
        }

        let dates = selection.selectedDates
            .compactMap { $0.date }
            .sorted()

        // Allow only if exactly 1 date is selected
        guard dates.count == 1 else { return }

        let result = dates.map {
            Calendar.current.dateComponents([.year, .month, .day], from: $0)
        }

        onDateSelectionComplete?(result)
        dismiss(animated: true)
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UICalendarSelectionMultiDateDelegate
extension CalendarPickerViewController: UICalendarSelectionMultiDateDelegate {
    func multiDateSelection(
        _ selection: UICalendarSelectionMultiDate,
        didSelectDate dateComponents: DateComponents
    ) {
        let selectedDates = selection.selectedDates
            .compactMap { $0.date }
            .sorted()

        guard selectedDates.count == 2 else { return }

        onDateSelectionComplete?(
            selectedDates.map {
                Calendar.current.dateComponents(
                    [.year, .month, .day], from: $0)
            }
        )
        dismiss(animated: true)
    }

    func multiDateSelection(
        _ selection: UICalendarSelectionMultiDate,
        didDeselectDate dateComponents: DateComponents
    ) {}
}

// MARK: - Presenting the Calendar Picker
extension UIViewController {
    func presentCalendarPicker(completion: @escaping ([DateComponents]) -> Void) {
        let calendarVC = CalendarPickerViewController()
        calendarVC.modalPresentationStyle = .pageSheet

        if let sheet = calendarVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
        }

        calendarVC.onDateSelectionComplete = completion

        present(calendarVC, animated: true)
    }
}
