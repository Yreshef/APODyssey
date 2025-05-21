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
    private let loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.tintColor = .label
        return spinner
    }()
    private var errorController: ErrorAlertController?

    // MARK: - Properties

    private let viewModel: GalleryViewModel
    private var cancellables = Set<AnyCancellable>()
    private var pictures: [PictureOfTheDay] = []
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = viewModel.selectedIndex {
            DispatchQueue.main.async {
                self.highlightSelectedCell(at: index)
                self.viewModel.selectedIndex = nil
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !pictures.isEmpty {
            loadingIndicator.stopAnimating()
        }
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
        
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
        ])
        
        view.bringSubviewToFront(loadingIndicator)
    }

    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.$pictures
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.pictures = items
                self?.collectionView.reloadData()
                self?.loadingIndicator.stopAnimating()
            }
            .store(in: &cancellables)
        
        viewModel.$updatedThumbnailID
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] id in
                guard let index = self?.pictures.firstIndex(where: { $0.id == id }) else { return }
                let indexPath = IndexPath(item: index, section: 0)
                
                guard let cell = self?.collectionView.cellForItem(at: indexPath) else { return }
                
                let imageData = self?.viewModel.thumbnails[id]
                
                if let expandedCell = cell as? ExpandedGalleryCell {
                    expandedCell.setImage(from: imageData)
                } else if let collapsedCell = cell as? CollapsedGalleryCell {
                    collapsedCell.setImage(from: imageData)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
            }
            .store(in: &cancellables)
        
        errorController = bindErrorAlert(to: self, from: viewModel.errorMessagePublisher)
    }
    
    func highlightSelectedCell(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        
        collectionView.layoutIfNeeded() // ensure cell layout is done
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])

        // Optional: Reload the item to trigger visual update in case it's offscreen
        collectionView.reloadItems(at: [indexPath])
    }


}

extension GalleryViewController: UICollectionViewDelegate,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let picture = pictures[indexPath.item]
        let isExpanded = viewModel.isExpanded(indexPath)

        if isExpanded {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ExpandedGalleryCell.reuseID,
                for: indexPath
            ) as? ExpandedGalleryCell else {
                return UICollectionViewCell()
            }

            cell.configure(with: picture)
            viewModel.loadThumbnails(for: picture)
            
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

            cell.configure(with: picture)
            viewModel.loadThumbnails(for: picture)

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
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])

            let isSelected = collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let picture = pictures[indexPath.item]
           let image = viewModel.thumbnails[picture.id]

           if let expanded = cell as? ExpandedGalleryCell {
               expanded.setImage(from: image)
           } else if let collapsed = cell as? CollapsedGalleryCell {
               collapsed.setImage(from: image)
           }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let picture = pictures[indexPath.item]
        viewModel.didSelectItem(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isExpanded = viewModel.isExpanded(indexPath)
        let width = collectionView.bounds.width - 24
        let height: CGFloat = isExpanded ? 440 : 116
        return CGSize(width: width, height: height)
    }
}
