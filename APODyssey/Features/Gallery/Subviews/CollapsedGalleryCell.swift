//
//  CollapsedGalleryCell.swift
//  APODyssey
//
//  Created by Yohai on 20/05/2025.
//

import UIKit

final class CollapsedGalleryCell: UICollectionViewCell {
    static let reuseID = "CollapsedGalleryCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    override var isSelected: Bool {
            didSet {
                updateAppearance()
            }
        }


    var onImageTap: (() -> Void)?

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
        imageView.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(
            target: self, action: #selector(handleTap))
        imageView.addGestureRecognizer(tap)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .white

        self.contentView.addSubview(imageView)
        self.contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 10),
            imageView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -10),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100),

            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(
                equalTo: imageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }

    func configure(with model: PictureOfTheDay) {
        titleLabel.text = model.title
        imageView.image = model.thumbnail100 ?? model.image
        imageView.backgroundColor =
            imageView.image == nil ? .secondarySystemFill : .clear
    }

    @objc private func handleTap() {
        onImageTap?()
    }

    func setSelected(_ selected: Bool) {
        isSelected = selected
    }

    private func updateAppearance() {
        contentView.layer.borderWidth = isSelected ? 2 : 0
        contentView.layer.borderColor = isSelected ? UIColor.white.cgColor : nil
    }
}
