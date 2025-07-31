//
//  SearchViewController.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/29/25.
//

import Alamofire
import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

private struct BookSearchResponse: Codable {
    let documents: [Document]
    struct Document: Codable {
        let title: String
        let authors: [String]
        let contents: String
        let sale_price: Int
        let thumbnail: String
    }
}

struct BookItem {
    let imageURL: URL?
    let title: String
    let author: String
    let description: String
    let priceText: String
}

final class SearchViewController: UIViewController {
    private let searchBar = UISearchBar().then {
        $0.placeholder = "책 제목 또는 저자를 입력하세요"
        $0.searchBarStyle = .minimal
        $0.returnKeyType = .search
    }

    private let scrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
    }

    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
    }

    private let tableView = UITableView().then {
        $0.register(BookCell.self, forCellReuseIdentifier: BookCell.identifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 120
        $0.separatorStyle = .none
    }

    private let disposeBag = DisposeBag()
    private let apiKey = "536e08fd6cae2a372119d07eb9bee824"
    private let books = BehaviorRelay<[BookItem]>(value: [])
    private let viewModel = SearchViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "검색"
        view.backgroundColor = .systemBackground

        setupLayout()
        bindBanner()
        bindSearch()
        bindTable()

        viewModel.loadBanner()
    }

    private func setupLayout() {
        view.addSubview(searchBar)
        view.addSubview(scrollView)
        view.addSubview(tableView)

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        scrollView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.height.equalTo(scrollView.frameLayoutGuide)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func bindBanner() {
        view.layoutIfNeeded()
        viewModel.bannerData
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] items in
                guard let self = self else { return }
                self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                for data in items {
                    let container = UIView()
                    self.stackView.addArrangedSubview(container)
                    container.snp.makeConstraints {
                        $0.width.equalTo(self.scrollView.frameLayoutGuide)
                        $0.height.equalTo(self.scrollView.frameLayoutGuide)
                    }
                    let banner = BannerView()
                    banner.configure(with: data)
                    container.addSubview(banner)
                    banner.snp.makeConstraints {
                        $0.center.equalToSuperview()
                        $0.width.equalTo(self.view.bounds.width - 40)
                        $0.height.equalToSuperview()
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    private func bindSearch() {
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [unowned self] text in
                let headers: HTTPHeaders = [
                    "Authorization": "KakaoAK \(apiKey)"
                ]
                AF.request(
                    "https://dapi.kakao.com/v3/search/book",
                    parameters: ["query": text],
                    headers: headers
                )
                .validate()
                .responseDecodable(of: BookSearchResponse.self) { response in
                    switch response.result {
                    case .success(let resp):
                        let items = resp.documents.map {
                            BookItem(
                                imageURL: URL(string: $0.thumbnail),
                                title: $0.title,
                                author: $0.authors.joined(separator: ", "),
                                description: $0.contents,
                                priceText: "\($0.sale_price)원"
                            )
                        }
                        self.books.accept(items)

                    case .failure(let error):
                        print("Alamofire Error:", error)
                        self.books.accept([])
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    private func bindTable() {
        books
            .bind(to: tableView.rx.items(cellIdentifier: BookCell.identifier, cellType: BookCell.self)) { _, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(BookItem.self)
            .subscribe(onNext: { [weak self] item in
                let detailVC = BookDetailViewController()
                detailVC.configure(
                    title: item.title,
                    author: item.author,
                    description: item.description,
                    salePrice: item.priceText
                )
                let nav = UINavigationController(rootViewController: detailVC)
                nav.modalPresentationStyle = .automatic
                self?.present(nav, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

private class BookCell: UITableViewCell {
    static let identifier = "BookCell"

    private let thumb = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 4
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
            $0.width.equalTo(60)
            $0.height.equalTo(90)
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
        priceLabel.text = item.priceText
    }
}

@available(iOS 17.0, *)
#Preview {
    SearchViewController()
}
