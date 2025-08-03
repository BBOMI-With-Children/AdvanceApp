//
//  MyPageViewController.swift
//  AdvanceApp
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class MyPageViewController: UIViewController {
    // MARK: - UI

    private let tableView = UITableView().then {
        $0.register(BookCell.self, forCellReuseIdentifier: BookCell.identifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 120
        $0.separatorStyle = .none
    }

    private let emptyLabel = UILabel().then {
        $0.text = "담은 책이 없습니다"
        $0.font = .systemFont(ofSize: 18)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.isHidden = true
    }

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private let savedBooksRelay = BehaviorRelay<[BookItem]>(value: [])

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "담은 책"

        setupNavigationBar()
        setupLayout()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSavedBooks()
    }

    // MARK: - Navigation Bar

    private func setupNavigationBar() {
        let deleteAllButton = UIBarButtonItem(title: "전체 삭제", style: .plain, target: nil, action: nil)
        let addButton = UIBarButtonItem(title: "추가", style: .plain, target: nil, action: nil)

        navigationItem.leftBarButtonItem = deleteAllButton
        navigationItem.rightBarButtonItem = addButton

        deleteAllButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                // 전체 삭제
                SavedBookManager.shared.deleteAll()
                self.savedBooksRelay.accept([])
            })
            .disposed(by: disposeBag)

        addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard
                    let self = self,
                    let tabBar = self.tabBarController,
                    let nav = tabBar.viewControllers?.first as? UINavigationController,
                    let searchVC = nav.viewControllers.first as? SearchViewController
                else { return }

                // 1) 탭 전환
                tabBar.selectedIndex = 0
                // 2) 검색바 포커스
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    searchVC.activateSearchBar()
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    // MARK: - Binding

    private func bindViewModel() {
        // 1) 데이터 → 테이블
        savedBooksRelay
            .asDriver()
            .drive(tableView.rx.items(
                cellIdentifier: BookCell.identifier,
                cellType: BookCell.self
            )) { _, book, cell in
                cell.configure(with: book)
            }
            .disposed(by: disposeBag)

        // 2) 빈 상태 라벨 표시
        savedBooksRelay
            .map { !$0.isEmpty }
            .bind(to: emptyLabel.rx.isHidden)
            .disposed(by: disposeBag)

        // 3) 셀 선택 → 상세화면
        tableView.rx.modelSelected(BookItem.self)
            .subscribe(onNext: { [weak self] book in
                let detailVC = BookDetailViewController()
                detailVC.configure(with: book)
                let nav = UINavigationController(rootViewController: detailVC)
                self?.present(nav, animated: true)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Data

    private func loadSavedBooks() {
        let books = SavedBookManager.shared.getAll()
        savedBooksRelay.accept(books)
    }
}
