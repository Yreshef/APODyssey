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
    private var errorController: ErrorAlertController?

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
        viewModel.loadToday()
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
        
        viewModel.$image
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageData in
                if let imageData = imageData {
                    self?.mainView.imageView.image = UIImage(data: imageData)
                }
            }
            .store(in: &cancellables)
        
        errorController = bindErrorAlert(to: self, from: viewModel.errorMessagePublisher)
    }

    private func configureNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Select Date",
            style: .plain,
            target: self,
            action: #selector(selectDateTapped)
        )
    }

    @objc private func selectDateTapped() {
        presentCalendarPicker {
            [weak self] components in
            guard let self = self else { return }
            self.viewModel.handleUserDateSelection(components)
        }
    }
}
