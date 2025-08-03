//
//  SearchViewController.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/29/25.
//

import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import Then
import UIKit

// RxDataSources용 섹션 모델 타입
private typealias BookSection = SectionModel<String, BookItem>

final class SearchViewController: UIViewController {
    // 상단 검색바
    private let searchBar = UISearchBar().then {
        $0.placeholder = "책 제목 또는 저자를 입력하세요"
        $0.searchBarStyle = .minimal
        $0.returnKeyType = .search
    }

    // MARK: — 포커스용 공개 메서드

    /// MyPage에서 검색바에 포커스 주기 용도
    func activateSearchBar() {
        searchBar.becomeFirstResponder()
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

    private let recentBooksRelay = BehaviorRelay<[BookItem]>(value: [])
    private let recentCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.itemSize = CGSize(width: 100, height: 150)
            $0.minimumLineSpacing = 12
        }
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.showsHorizontalScrollIndicator = false
            $0.backgroundColor = .clear
        }
        cv.register(RecentBookCell.self,
                    forCellWithReuseIdentifier: RecentBookCell.identifier)
        return cv
    }()

    // 검색 결과 리스트
    private let tableView = UITableView().then {
        $0.register(BookCell.self, forCellReuseIdentifier: BookCell.identifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 120
        $0.separatorStyle = .none
    }

    private let disposeBag = DisposeBag()
    private let viewModel = SearchViewModel()
    private let bannerViewModel = BannerViewModel()

    // RxDataSources용 데이터소스
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<BookSection>(
        configureCell: { _, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: BookCell.identifier,
                for: indexPath
            ) as! BookCell
            cell.configure(with: item)
            return cell
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = ""
        view.backgroundColor = .systemBackground

        setupLayout()
        bindBanner()
        bindViewModel()
        bannerViewModel.loadBanner()
    }

    // 화면 보일 때 네비게이션 바 숨기기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // 네비게이션 바 다시 보이기
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(bannerScrollView)
        view.addSubview(searchBar)

        bannerScrollView.addSubview(bannerStackView)

        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
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

        recentCollectionView.snp.makeConstraints {
            $0.top.equalTo(bannerScrollView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(150)
        }

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

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        let input = SearchInput(
            queryText: searchBar.rx.text.orEmpty.asObservable()
        )
        let output = viewModel.transform(input)

        // RxDataSources로 테이블뷰 바인딩
        output.books
            .map { books in
                [BookSection(model: "검색 결과", items: books)]
            }
            .drive(tableView.rx.items(dataSource: dataSource))
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
