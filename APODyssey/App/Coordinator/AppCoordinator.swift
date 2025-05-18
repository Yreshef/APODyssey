//
//  AppCoordinator.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    var childCoordinators: [Coordinator] { get set }

    func start()
    func addChild(_ coordinator: Coordinator)
    func removeChild(_ coordinator: Coordinator)
    func childDidFinish(_ child: Coordinator?)
}

final class AppCoordinator: Coordinator {
    let window: UIWindow
    let navigationController: UINavigationController
    private var mainCoordinator: MainCoordinator?

    var childCoordinators: [Coordinator] = []

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    func start() {
        let mainCoordinator = MainCoordinator(navigationController: navigationController)

        addChild(mainCoordinator)
        self.mainCoordinator = mainCoordinator

        mainCoordinator.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    // MARK: - Coordinator Lifecycle Helpers
    
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
    
    func childDidFinish(_ child: (any Coordinator)?) {
        guard let child = child else { return }
        removeChild(child)
    }
}


