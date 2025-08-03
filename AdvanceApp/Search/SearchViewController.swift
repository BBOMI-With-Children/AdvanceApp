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

    private let recentTitleLabel = UILabel().then {
        $0.text = "📖 최근 본 책"
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .label
    }

    private let recentToggleButton = UIButton(type: .system).then {
        $0.setTitle("접기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14)
    }

    private var isRecentHidden = false

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

        recentCollectionView.contentInset = .init(top: 0, left: 20, bottom: 0, right: 20)

        recentToggleButton.addTarget(self,
                                     action: #selector(toggleRecentSection),
                                     for: .touchUpInside)

        setupLayout()

        view.bringSubviewToFront(recentTitleLabel)
        view.bringSubviewToFront(recentToggleButton)

        bindBanner()
        bindRecent()
        bindViewModel()
        bannerViewModel.loadBanner()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 네비게이션 바 숨기기
        navigationController?.setNavigationBarHidden(true, animated: false)
        // CoreData에서 최근 본 책 불러오기
        let recent = SavedBookManager.shared.getAll()
        recentBooksRelay.accept(recent)
    }

    // 네비게이션 바 다시 보이기
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Layout

    private func setupLayout() {
        [searchBar, bannerScrollView, recentTitleLabel, recentToggleButton, recentCollectionView, tableView]
            .forEach { view.addSubview($0) }

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

        recentTitleLabel.snp.makeConstraints {
            $0.top.equalTo(bannerScrollView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(20)
        }

        recentToggleButton.snp.makeConstraints {
            $0.centerY.equalTo(recentTitleLabel)
            $0.trailing.equalToSuperview().inset(20)
        }

        recentCollectionView.snp.makeConstraints {
            $0.top.equalTo(recentTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(150)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(recentCollectionView.snp.bottom).offset(16)
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

    private func bindRecent() {
        // 1) 데이터 → CollectionView
        recentBooksRelay
            .asDriver()
            .drive(recentCollectionView.rx.items(
                cellIdentifier: RecentBookCell.identifier,
                cellType: RecentBookCell.self
            )) { _, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)

        // 2) 탭 → 상세화면
        recentCollectionView.rx
            .modelSelected(BookItem.self)
            .subscribe(onNext: { [weak self] item in
                let detailVC = BookDetailViewController()
                detailVC.configure(with: item)
                let nav = UINavigationController(rootViewController: detailVC)
                nav.modalPresentationStyle = .automatic
                self?.present(nav, animated: true)
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

                // 1) CoreData에 저장
                SavedBookManager.shared.save(item)

                // 2) 클릭된 항목을 맨 앞에
                var recents = self.recentBooksRelay.value
                recents.insert(item, at: 0)
                self.recentBooksRelay.accept(recents)

                // 3) 상세화면으로 이동
                let detailVC = BookDetailViewController()
                detailVC.configure(with: item)
                let nav = UINavigationController(rootViewController: detailVC)
                nav.modalPresentationStyle = .automatic
                self.present(nav, animated: true)
            })
            .disposed(by: disposeBag)
    }

    @objc private func toggleRecentSection() {
        isRecentHidden.toggle()
        // 버튼 타이틀 교체
        let title = isRecentHidden ? "펼치기" : "접기"
        recentToggleButton.setTitle(title, for: .normal)

        // 컬렉션뷰 숨김
        recentCollectionView.isHidden = isRecentHidden

        // 테이블뷰 제약 재설정
        tableView.snp.remakeConstraints {
            let topAnchor = isRecentHidden
                ? recentTitleLabel.snp.bottom
                : recentCollectionView.snp.bottom
            $0.top.equalTo(topAnchor).offset(16)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        // 애니메이션으로 레이아웃 반영
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    SearchViewController()
}
