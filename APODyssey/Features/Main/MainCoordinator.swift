//
//  MainCoordinator.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import UIKit
import SwiftUI

final class MainCoordinator: NSObject, Coordinator, UINavigationControllerDelegate {

    let navigationController: UINavigationController
    private let dependencies: DependencyProviding
    private weak var galleryVC: GalleryViewController?

    init(
        navigationController: UINavigationController,
        dependencies: DependencyProviding
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        super.init()
    }

    func start() {
        let viewModel = MainViewModel(
            repository: dependencies.pictureRepository)
        
        viewModel.onDateRangeSelected = { [weak self] start, end in
            self?.showGallery(start: start, end: end)
        }
        
        viewModel.onDateSelected = { [weak self] date in
            self?.showDetail(for: date)
        }

        let mainVC = MainViewController(viewModel: viewModel)
        mainVC.view.backgroundColor = .systemBackground
        mainVC.title = "APODyssey"
        navigationController.setViewControllers([mainVC], animated: false)
    }

    private func showDetail(for date: Date) {
        let viewModel = PictureDetailViewModel(repository: dependencies.pictureRepository, date: date)
        let detailsView = PictureDetailView(viewModel: viewModel)
        let controller = UIHostingController(rootView: detailsView)
        navigationController.pushViewController(controller, animated: true)
    }
    
    private func showDetail(with pictures: [PictureOfTheDay], index: Int) {
        let viewModel = PictureDetailViewModel(repository: dependencies.pictureRepository, pictures: pictures, initialIndex: index)
        
        viewModel.onDismiss = { [weak self] index in
            self?.galleryVC?.highlightSelectedCell(at: index)
        }
        let detailsView = PictureDetailView(viewModel: viewModel)
        let controller = UIHostingController(rootView: detailsView)
        navigationController.pushViewController(controller, animated: true)
    }

    private func showGallery(start: Date, end: Date) {
        let viewModel = GalleryViewModel(repository: dependencies.pictureRepository,
                                         startDate: start,
                                         endDate: end)
        
        viewModel.onImageTapped = { [weak self] pictures, index in
            self?.showDetail(with: pictures, index: index)
        }
        
        let galleryVC = GalleryViewController(viewModel: viewModel)
        self.galleryVC = galleryVC
        galleryVC.view.backgroundColor = .systemBackground
        navigationController.pushViewController(galleryVC, animated: true)
    }
}
