//
//  MainView.swift
//  APODyssey
//
//  Created by Yohai on 18/05/2025.
//

import UIKit

final class MainView: UIView {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let imageView = UIImageView()
    let dateLabel = UILabel()
    let explanationLabel = UILabel()
    let copyrightLabel = UILabel()
    let hash1Label = UILabel()
    let hash2Label = UILabel()
    let activityIndicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupLayout()
        styleComponents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViewHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        [imageView,
         dateLabel,
         explanationLabel,
         copyrightLabel,
         hash1Label,
         hash2Label,
         activityIndicator
        ].forEach { contentView.addSubview($0) }
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.75)
        ])
        let labels: [UILabel] = [dateLabel, explanationLabel, copyrightLabel, hash1Label, hash2Label]
        var previous = imageView as UIView
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 12),
                label.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
            ])
            previous = label
        }
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func styleComponents() {
        backgroundColor = .systemBackground
        imageView.contentMode = .scaleAspectFit
        dateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        explanationLabel.font = .systemFont(ofSize: 14)
        explanationLabel.numberOfLines = 0
        copyrightLabel.font = .systemFont(ofSize: 12)
        copyrightLabel.textColor = .secondaryLabel
        [hash1Label, hash2Label].forEach {
            $0.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        }
        activityIndicator.hidesWhenStopped = true
    }

    /// Configures the view with the given picture data.
    func configure(with picture: PictureOfTheDay) {
        imageView.image = picture.image
        dateLabel.text = picture.date
        explanationLabel.text = picture.explanation
        copyrightLabel.text = picture.copyright
        hash1Label.text = "Hash1: \(picture.hash1)"
        hash2Label.text = "Hash2: \(picture.hash2)"
    }

    /// Shows or hides the loading indicator.
    func setLoading(_ loading: Bool) {
        loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}
