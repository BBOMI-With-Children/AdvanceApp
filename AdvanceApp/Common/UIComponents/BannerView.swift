//
//  BannerView.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/29/25.
//

import UIKit

struct BannerViewData {
    let explain: String
    let title: String
    let imageName: String
    let backgroundColor: UIColor
}

final class BannerView: UIView {
    // MARK: - Subviews

    private let containerView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        return v
    }()

    private let explainLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = .label
        lbl.numberOfLines = 2
        return lbl
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.numberOfLines = 1
        return lbl
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 4
        return iv
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not supported")
    }

    // MARK: - Layout

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 160)
    }

    private func setupHierarchy() {
        addSubview(containerView)
        [explainLabel, titleLabel, imageView].forEach { containerView.addSubview($0) }
    }

    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        explainLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            explainLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            explainLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            explainLabel.trailingAnchor.constraint(lessThanOrEqualTo: imageView.leadingAnchor, constant: -8),

            titleLabel.leadingAnchor.constraint(equalTo: explainLabel.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: explainLabel.bottomAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8),

            imageView.widthAnchor.constraint(equalToConstant: 72),
            imageView.heightAnchor.constraint(equalToConstant: 106),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -36),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    // MARK: - Configuration

    func configure(with data: BannerViewData) {
        containerView.backgroundColor = data.backgroundColor
        explainLabel.text = data.explain
        titleLabel.text = data.title
        imageView.image = UIImage(named: data.imageName)
    }
}
