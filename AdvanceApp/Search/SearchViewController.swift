//
//  SearchViewController.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/29/25.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class SearchViewController: UIViewController {
    private let searchBar = UISearchBar().then {
        $0.placeholder = "책 제목 또는 저자를 입력하세요"
        $0.searchBarStyle = .minimal
        $0.returnKeyType = .search
    }

    private let bannerScrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
    }

    private let bannerStackView = UIStackView().then {
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
    private let viewModel = SearchViewModel()
    private let bannerViewModel = BannerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "검색"
        view.backgroundColor = .systemBackground

        setupLayout()
        bindBanner()
        bindViewModel()

        bannerViewModel.loadBanner()
    }

    private func setupLayout() {
        [searchBar, bannerScrollView, tableView].forEach { view.addSubview($0) }
        bannerScrollView.addSubview(bannerStackView)

        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        bannerScrollView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }
        bannerStackView.snp.makeConstraints {
            $0.edges.equalTo(bannerScrollView.contentLayoutGuide)
            $0.height.equalTo(bannerScrollView.frameLayoutGuide)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(bannerScrollView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func bindBanner() {
        view.layoutIfNeeded()
        bannerViewModel.bannerData
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] items in
                guard let self = self else { return }
                self.bannerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                for data in items {
                    let container = UIView()
                    self.bannerStackView.addArrangedSubview(container)
                    container.snp.makeConstraints {
                        $0.width.equalTo(self.bannerScrollView.frameLayoutGuide)
                        $0.height.equalTo(self.bannerScrollView.frameLayoutGuide)
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

    private func bindViewModel() {
        let input = SearchInput(
            queryText: searchBar.rx.text.orEmpty.asObservable()
        )
        let output = viewModel.transform(input)

        output.books
            .drive(tableView.rx.items(
                cellIdentifier: BookCell.identifier,
                cellType: BookCell.self
            )) { (_: Int, item: BookItem, cell: BookCell) in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)

        tableView.rx
            .modelSelected(BookItem.self)
            .subscribe(onNext: { [weak self] (item: BookItem) in
                let detailVC = BookDetailViewController()
                detailVC.configure(
                    title: item.title,
                    author: item.author,
                    description: item.description,
                    salePrice: item.priceText,
                    imageURL: item.imageURL
                )
                let nav = UINavigationController(rootViewController: detailVC)
                nav.modalPresentationStyle = .automatic
                self?.present(nav, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

@available(iOS 17.0, *)
#Preview {
    SearchViewController()
}
