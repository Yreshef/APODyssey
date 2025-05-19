//
//  MainViewController.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import Combine
import UIKit

final class MainViewController: UIViewController {

    private let viewModel: MainViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var mainView = MainView()
    
    // Coordinator callback
    var onSelectDateOrRange: (() -> Void)?

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        bindViewModel()
        viewModel.loadWorkingImage()
    }

    private func bindViewModel() {
        viewModel.$picture
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pic in
                self?.mainView.configure(with: pic)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.mainView.setLoading(loading)
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] msg in
                self?.showError(msg)
            }
            .store(in: &cancellables)
    }

    private func configureNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Select Date",
            style: .plain,
            target: self,
            action: #selector(selectDateTapped)
        )
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func selectDateTapped() {
        presentCalendarPicker() {
            [weak self] components in
            guard let self = self else { return }
            self.viewModel.handleUserDateSelection(components)
        }
    }
}
