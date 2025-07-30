//
//  SearchViewController.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/29/25.
//

import SnapKit
import Then
import UIKit

struct BookItem {
    let image: UIImage?
    let title: String
    let author: String
    let description: String
    let price: String
}

class SearchViewController: UIViewController {
    private let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.estimatedRowHeight = 140
        $0.rowHeight = UITableView.automaticDimension
    }

    private let dummyBooks: [BookItem] = [
        BookItem(
            image: UIImage(named: "conan_poster"),
            title: "미움 받을 용기",
            author: "기시미 이치로",
            description: "인간은 변할 수 있고, 누구나 행복해질 수 있다.",
            price: "14,900원"
        ),
        BookItem(
            image: UIImage(named: "almond_poster"),
            title: "아몬드",
            author: "손원평",
            description: "감정을 느끼지 못하는 소년 이야기.",
            price: "15,000원"
        ),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "검색"
        view.backgroundColor = .systemBackground
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        tableView.register(BookTableViewCell.self,
                           forCellReuseIdentifier: BookTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        return dummyBooks.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: BookTableViewCell.identifier,
                                 for: indexPath)
            as! BookTableViewCell
        cell.configure(with: dummyBooks[indexPath.row])
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath)
    {
        let detailVC = BookDetailViewController()
        let nav = UINavigationController(rootViewController: detailVC)
        nav.modalPresentationStyle = .automatic
        present(nav, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private class BookTableViewCell: UITableViewCell {
    static let identifier = "BookTableViewCell"

    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 4
        $0.backgroundColor = .secondarySystemFill
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.numberOfLines = 1
    }

    private let authorLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 1
    }

    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
    }

    private let priceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textAlignment = .right
    }

    private let separatorView = UIView().then {
        $0.backgroundColor = .lightGray
    }

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [thumbnailImageView,
         titleLabel,
         authorLabel,
         descriptionLabel,
         priceLabel,
         separatorView].forEach { contentView.addSubview($0) }

        thumbnailImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(12)
            $0.width.equalTo(76)
            $0.height.equalTo(108)
        }

        priceLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(thumbnailImageView)
            $0.width.lessThanOrEqualTo(80)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(priceLabel.snp.leading).offset(-8)
        }

        authorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(titleLabel)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(authorLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(titleLabel)
        }

        separatorView.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(0.5)
            $0.bottom.equalToSuperview().inset(20)
        }
    }

    func configure(with item: BookItem) {
        thumbnailImageView.image = item.image
        titleLabel.text = item.title
        authorLabel.text = item.author
        descriptionLabel.text = item.description
        priceLabel.text = item.price
    }
}

@available(iOS 17.0, *)
#Preview {
    SearchViewController()
}
