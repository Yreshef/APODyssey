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
        titleLabel.textColor = .label
        
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 10),
            imageView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -10),
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

    private func updateAppearance() {
        contentView.layer.borderWidth = isSelected ? 2 : 0
        contentView.layer.borderColor = isSelected ? UIColor.label.cgColor : nil
    }

    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutAttributes.frame.size.height = 116
        return layoutAttributes
    }
}
