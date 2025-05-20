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
        layout.itemSize = CGSize(width: view.bounds.width - 32, height: 116)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    private var errorController: ErrorAlertController?

    // MARK: - Properties

    private let viewModel: GalleryViewModel
    private var cancellables = Set<AnyCancellable>()
    private var items: [PictureOfTheDay] = []

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
        collectionView.register(
            GalleryCell.self, forCellWithReuseIdentifier: GalleryCell.reuseID)

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
    UICollectionViewDataSource
{
    func collectionView(
        _ collectionView: UICollectionView, numberOfItemsInSection section: Int
    ) -> Int {
        items.count
    }

    func collectionView(
        _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GalleryCell.reuseID, for: indexPath)
                as? GalleryCell
        else {
            return UICollectionViewCell()
        }

        let item = items[indexPath.item]
        cell.configure(with: item)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath
    ) {
        let item = items[indexPath.item]
        viewModel.didSelectItem(item)
    }
}
