//
//  BookDetailViewController.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/30/25.
//

import Kingfisher
import SnapKit
import Then
import UIKit

final class BookDetailViewController: UIViewController {
    private let thumbImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .secondarySystemFill
    }

    private let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        $0.numberOfLines = 0
    }

    private let authorLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .secondaryLabel
    }

    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.numberOfLines = 0
    }

    private let priceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .systemBlue
    }

    private let infoStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 8
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    private func setupLayout() {
        [thumbImageView, infoStack].forEach { view.addSubview($0) }

        for item in [titleLabel, authorLabel, descriptionLabel, priceLabel] {
            infoStack.addArrangedSubview(item)
        }

        infoStack.setCustomSpacing(4, after: titleLabel)
        infoStack.setCustomSpacing(12, after: authorLabel)
        infoStack.setCustomSpacing(20, after: descriptionLabel)

        thumbImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(260)
        }

        infoStack.snp.makeConstraints { make in
            make.top.equalTo(thumbImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16)
        }
    }

    func configure(title: String,
                   author: String,
                   description: String,
                   salePrice: String,
                   imageURL: URL?)
    {
        titleLabel.text = title
        authorLabel.text = author
        descriptionLabel.text = description
        priceLabel.text = salePrice

        if let imageURL = imageURL {
            thumbImageView.kf.setImage(with: imageURL)
        }
    }
}
