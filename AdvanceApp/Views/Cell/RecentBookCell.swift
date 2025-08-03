//
//  RecentBookCell.swift
//  AdvanceApp
//
//  Created by 노가현 on 8/4/25.
//

import Kingfisher
import SnapKit
import Then
import UIKit

final class RecentBookCell: UICollectionViewCell {
    static let identifier = "RecentBookCell"
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.backgroundColor = .secondarySystemFill
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(with item: BookItem) {
        if let url = item.imageURL {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = UIImage(systemName: "book")
        }
    }
}
