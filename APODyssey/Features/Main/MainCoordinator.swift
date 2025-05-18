//
//  MainCoordinator.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import UIKit

final class MainCoordinator: NSObject, Coordinator, UINavigationControllerDelegate {
    
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    private let dependencies: DependencyProviding
    private var viewControllerToCoordinator: [UIViewController: Coordinator] = [:]

    init(navigationController: UINavigationController, dependencies: DependencyProviding) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        super.init()
        self.navigationController.delegate = self
    }

    func start() {
        let MainViewController = MainViewController()
        MainViewController.view.backgroundColor = .systemBackground
        MainViewController.title = "APODyssey"
        navigationController.setViewControllers([MainViewController], animated: false)
    }

    // MARK: - Coordinator Helpers
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    func register(_ viewController: UIViewController, for coordinator: Coordinator) {
        viewControllerToCoordinator[viewController] = coordinator
    }
    
    func childDidFinish(_ child: Coordinator?) {
        guard let child = child else { return }
        removeChild(child)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
              !navigationController.viewControllers.contains(fromViewController) else {
            return
        }
        
        if let coordinator = viewControllerToCoordinator[fromViewController] {
            removeChild(coordinator)
            viewControllerToCoordinator[fromViewController] = nil
        }
    }
}
