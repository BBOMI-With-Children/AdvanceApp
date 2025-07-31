//
//  BookDetailViewController.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/30/25.
//

import SnapKit
import Then
import UIKit

final class BookDetailViewController: UIViewController {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    private func setupLayout() {
        for item in [titleLabel, authorLabel, descriptionLabel, priceLabel] {
            view.addSubview(item)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(titleLabel)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(12)
            make.leading.trailing.equalTo(titleLabel)
        }
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(titleLabel)
        }
    }

    func configure(title: String,
                   author: String,
                   description: String,
                   salePrice: String)
    {
        titleLabel.text = title
        authorLabel.text = author
        descriptionLabel.text = description
        priceLabel.text = salePrice
    }
}
