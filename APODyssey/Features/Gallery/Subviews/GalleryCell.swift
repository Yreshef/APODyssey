//
//  GalleryCell.swift
//  APODyssey
//
//  Created by Yohai on 19/05/2025.
//

import UIKit

final class GalleryCell: UICollectionViewCell {
    static let reuseID = "GalleryCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 2

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 12),
            imageView.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: 8),
            imageView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -8),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.leadingAnchor.constraint(
                equalTo: imageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(
                equalTo: imageView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -12),
        ])
    }

    func configure(with model: PictureOfTheDay) {
        titleLabel.text = model.title
        imageView.image = model.thumbnail100 ?? model.image
        imageView.backgroundColor =
            imageView.image == nil ? .secondarySystemFill : .clear
    }
}
