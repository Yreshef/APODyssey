//
//  ExpandedGalleryCell.swift
//  APODyssey
//
//  Created by Yohai on 20/05/2025.
//

import UIKit

final class ExpandedGalleryCell: UICollectionViewCell {
    static let reuseID = "ExpandedGalleryCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let hashLabel = UILabel()
    private let containerStack = UIStackView()
    
    var onImageTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        // Image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        imageView.addGestureRecognizer(tap)

        // Labels
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .label

        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .lightGray

        hashLabel.font = .systemFont(ofSize: 14)
        hashLabel.textColor = .lightGray

        // Stack
        containerStack.axis = .vertical
        containerStack.spacing = 8
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.addArrangedSubview(imageView)
        containerStack.addArrangedSubview(titleLabel)
        containerStack.addArrangedSubview(dateLabel)
        containerStack.addArrangedSubview(hashLabel)

        contentView.addSubview(containerStack)
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with model: PictureOfTheDay) {
        titleLabel.text = model.title
        dateLabel.text = "Date: \(model.date)"
        hashLabel.text = "Hash: \(model.hash1)"

    }
    
    func setImage(from data: Data?) {
        let newImage = data.flatMap(UIImage.init) ?? UIImage(named: "placeholder")

        guard imageView.image !== newImage else { return }

        imageView.image = newImage
        imageView.backgroundColor = (newImage == nil) ? .secondarySystemFill : .clear
    }
    
    @objc private func handleTap() {
        onImageTap?()
    }
}
