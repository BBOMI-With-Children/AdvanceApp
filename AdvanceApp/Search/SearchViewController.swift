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
    // 상단 검색바
    private let searchBar = UISearchBar().then {
        $0.placeholder = "책 제목 또는 저자를 입력하세요"
        $0.searchBarStyle = .minimal
        $0.returnKeyType = .search
    }

    // 가로 스크롤용 배너 영역
    private let bannerScrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
    }

    private let bannerStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
    }

    // 검색 결과 리스트
    private let tableView = UITableView().then {
        $0.register(BookCell.self, forCellReuseIdentifier: BookCell.identifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 120
        $0.separatorStyle = .none
    }

    func activateSearchBar() {
        searchBar.becomeFirstResponder()
    }

    private let disposeBag = DisposeBag()
    private let viewModel = SearchViewModel()
    private let bannerViewModel = BannerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = ""
        view.backgroundColor = .systemBackground

        setupLayout()
        bindBanner()
        bindViewModel()

        bannerViewModel.loadBanner()
    }

    // MARK: - Layout

    private func setupLayout() {
        // 서브뷰 추가
        [searchBar, bannerScrollView, tableView].forEach { view.addSubview($0) }
        bannerScrollView.addSubview(bannerStackView)

        // 검색바 제약
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset((UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0))
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        // 배너 제약
        bannerScrollView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }
        bannerStackView.snp.makeConstraints {
            $0.edges.equalTo(bannerScrollView.contentLayoutGuide)
            $0.height.equalTo(bannerScrollView.frameLayoutGuide)
        }
        // 테이블뷰 제약
        tableView.snp.makeConstraints {
            $0.top.equalTo(bannerScrollView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    // MARK: - Banner Binding

    private func bindBanner() {
        view.layoutIfNeeded()
        bannerViewModel.bannerData
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] items in
                guard let self = self else { return }
                // 이전 배너 제거
                self.bannerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                // 새 배너 추가
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
        // 입력 : 검색바 텍스트
        let input = SearchInput(
            queryText: searchBar.rx.text.orEmpty.asObservable()
        )
        let output = viewModel.transform(input)

        // 결과 : 테이블뷰에 표시
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
            .subscribe(onNext: { [weak self] item in
                guard let self = self else { return }
                let detailVC = BookDetailViewController()
                detailVC.configure(with: item)
                let nav = UINavigationController(rootViewController: detailVC)
                nav.modalPresentationStyle = .automatic
                self.present(nav, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

@available(iOS 17.0, *)
#Preview {
    SearchViewController()
}
