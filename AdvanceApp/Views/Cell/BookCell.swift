//
//  BookCell.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/31/25.
//

import Kingfisher
import SnapKit
import Then
import UIKit

final class BookCell: UITableViewCell {
    static let identifier = "BookCell"

    private let thumb = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.backgroundColor = .secondarySystemFill
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.numberOfLines = 2
    }

    private let authorLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
    }

    private let descLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 2
    }

    private let priceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .bold)
        $0.textAlignment = .right
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        for item in [thumb, titleLabel, authorLabel, descLabel, priceLabel] {
            contentView.addSubview(item)
        }

        thumb.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(12)
            $0.width.equalTo(60); $0.height.equalTo(90)
        }
        priceLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(thumb)
            $0.width.lessThanOrEqualTo(80)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(thumb)
            $0.leading.equalTo(thumb.snp.trailing).offset(12)
            $0.trailing.equalTo(priceLabel.snp.leading).offset(-8)
        }
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(titleLabel)
        }
        descLabel.snp.makeConstraints {
            $0.top.equalTo(authorLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(titleLabel)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) 미지원") }

    func configure(with item: BookItem) {
        if let url = item.imageURL {
            thumb.kf.setImage(with: url, placeholder: UIImage(systemName: "book"))
        } else {
            thumb.image = UIImage(systemName: "book")
        }
        titleLabel.text = item.title
        authorLabel.text = item.author
        descLabel.text = item.description

        let sale = item.priceText
        if sale == "-1원" || sale == "0원" {
            priceLabel.text = item.price
        } else {
            priceLabel.text = sale
        }
    }
}
