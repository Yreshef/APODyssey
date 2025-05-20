//
//  GalleryViewController.swift
//  APODyssey
//
//  Created by Yohai on 19/05/2025.
//

import Combine
import UIKit

final class GalleryViewController: UIViewController {

    // MARK: UI

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .zero
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.allowsSelection = true
        cv.allowsMultipleSelection = false
        return cv
    }()
    
    private var errorController: ErrorAlertController?

    // MARK: - Properties

    private let viewModel: GalleryViewModel
    private var cancellables = Set<AnyCancellable>()
    private var items: [PictureOfTheDay] = []
    
    let collapsedHeight: CGFloat = 116
    let expandedHeight: CGFloat = 380

    // MARK: ViewModel Callbacks

    var onItemSelected: ((PictureOfTheDay) -> Void)?

    init(viewModel: GalleryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchPictures()
        setupUI()
        bindViewModel()
    }
    
    deinit {
        print("Gallery deinit")
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollapsedGalleryCell.self, forCellWithReuseIdentifier: CollapsedGalleryCell.reuseID)
        collectionView.register(ExpandedGalleryCell.self, forCellWithReuseIdentifier: ExpandedGalleryCell.reuseID)

        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
        ])
    }

    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.items = items
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        errorController = bindErrorAlert(to: self, from: viewModel.errorMessagePublisher)
    }
}

extension GalleryViewController: UICollectionViewDelegate,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let item = items[indexPath.item]
        let isExpanded = viewModel.isExpanded(indexPath)

        if isExpanded {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ExpandedGalleryCell.reuseID,
                for: indexPath
            ) as? ExpandedGalleryCell else {
                return UICollectionViewCell()
            }

            cell.configure(with: item)
            
            cell.onImageTap = { [weak self] in
                self?.viewModel.toggleExpansion(at: indexPath)
                self?.collectionView.performBatchUpdates {
                    self?.collectionView.reloadItems(at: [indexPath])
                }
            }
       
            return cell
            
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CollapsedGalleryCell.reuseID,
                for: indexPath
            ) as? CollapsedGalleryCell else {
                return UICollectionViewCell()
            }

            cell.configure(with: item)

            cell.onImageTap = { [weak self] in
                guard let self else { return }

                let previous = viewModel.expandedIndexPath
                viewModel.toggleExpansion(at: indexPath)

                var toReload: [IndexPath] = [indexPath]
                if let previous, previous != indexPath {
                    toReload.append(previous)
                }

                collectionView.performBatchUpdates {
                    collectionView.reloadItems(at: toReload)
                }
            }
            
            let isSelected = collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false
            cell.setSelected(isSelected)
            
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        viewModel.didSelectItem(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isExpanded = viewModel.isExpanded(indexPath)
        let width = collectionView.bounds.width - 24
        let height: CGFloat = isExpanded ? 440 : 116
        return CGSize(width: width, height: height)
    }
}
