//
//  MainCoordinator.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import UIKit

final class MainCoordinator: NSObject, Coordinator,
    UINavigationControllerDelegate
{

    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    private let dependencies: DependencyProviding
    private var viewControllerToCoordinator: [UIViewController: Coordinator] =
        [:]

    init(
        navigationController: UINavigationController,
        dependencies: DependencyProviding
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        super.init()
        self.navigationController.delegate = self
    }

    func start() {
        let viewModel = MainViewModel(
            repository: dependencies.pictureRepository)
        let mainVC = MainViewController(viewModel: viewModel)
        mainVC.view.backgroundColor = .systemBackground
        mainVC.title = "APODyssey"

        register(mainVC, for: self)

        navigationController.setViewControllers([mainVC], animated: false)
    }

    private func showDateSelection() {
        //TODO: implement date picker
    }

    private func showDetail(for date: Date) {
        //TODO: implement detail navigation
    }

    private func showList(start: Date, end: Date) {
        //TODO: implement list navigation
    }

    // MARK: - Coordinator Helpers
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }

    func register(
        _ viewController: UIViewController, for coordinator: Coordinator
    ) {
        viewControllerToCoordinator[viewController] = coordinator
    }

    func childDidFinish(_ child: Coordinator?) {
        guard let child = child else { return }
        removeChild(child)
    }

    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController, animated: Bool
    ) {
        guard
            let fromViewController = navigationController.transitionCoordinator?
                .viewController(forKey: .from),
            !navigationController.viewControllers.contains(fromViewController)
        else {
            return
        }

        if let coordinator = viewControllerToCoordinator[fromViewController] {
            removeChild(coordinator)
            viewControllerToCoordinator[fromViewController] = nil
        }
    }
}
