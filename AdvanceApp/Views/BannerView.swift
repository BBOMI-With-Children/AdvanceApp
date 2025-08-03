//
//  BannerView.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/29/25.
//

import SnapKit
import Then
import UIKit

final class BannerView: UIView {
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 12
    }

    private let explainLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 2
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 2
    }

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 4
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(containerView)
        [explainLabel, titleLabel, imageView].forEach { containerView.addSubview($0) }

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        explainLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(25)
            $0.top.equalToSuperview().offset(40)
            $0.trailing.lessThanOrEqualTo(imageView.snp.leading).offset(-8)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(explainLabel)
            $0.top.equalTo(explainLabel.snp.bottom).offset(10)
            $0.trailing.lessThanOrEqualTo(imageView.snp.leading).offset(-8)
            $0.bottom.lessThanOrEqualToSuperview().offset(-8)
        }

        imageView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 72, height: 106))
            $0.trailing.equalToSuperview().inset(36)
            $0.centerY.equalToSuperview()
        }
    }

    func configure(with data: BannerViewData) {
        containerView.backgroundColor = data.backgroundColor
        explainLabel.text = data.explain
        titleLabel.text = data.title
        imageView.image = UIImage(named: data.imageName)
    }
}
