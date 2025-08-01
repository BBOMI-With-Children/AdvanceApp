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
        $0.textColor = .label
        $0.textAlignment = .right
    }

    // StackView: 제목, 저자, 설명, 가격 순서로
    private let infoStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 0
        $0.setContentHuggingPriority(.required, for: .vertical)
    }

    private let bottomContainer = UIView().then {
        $0.backgroundColor = .clear
    }

    // MARK: - Buttons
    private let closeButton = UIButton(type: .system).then {
        $0.setTitle("X", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 8
    }

    private let saveButton = UIButton(type: .system).then {
        $0.setTitle("담기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.backgroundColor = UIColor(named: "mainColor")
        $0.layer.cornerRadius = 8
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        bindActions()
    }

    private func setupLayout() {
        [thumbImageView, infoStack, bottomContainer].forEach { view.addSubview($0) }

        [titleLabel, authorLabel, descriptionLabel, priceLabel].forEach {
            infoStack.addArrangedSubview($0)
        }

        [closeButton, saveButton].forEach { bottomContainer.addSubview($0) }

        infoStack.setCustomSpacing(20, after: titleLabel)
        infoStack.setCustomSpacing(8, after: authorLabel)
        infoStack.setCustomSpacing(20, after: descriptionLabel)

        // Layout constraints
        thumbImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(260)
        }

        infoStack.snp.makeConstraints { make in
            make.top.equalTo(thumbImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualTo(bottomContainer.snp.top).offset(-16)
        }
        bottomContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(50)
        }

        closeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(44)
        }

        saveButton.snp.makeConstraints { make in
            make.leading.equalTo(closeButton.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
    }

    private func bindActions() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    @objc private func didTapSave() {
        print("담기 버튼 탭")
    }

    // 화면에 데이터 세팅
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
