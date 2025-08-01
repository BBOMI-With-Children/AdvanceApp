//
//  MyPageViewController.swift
//  AdvanceApp
//

import SnapKit
import Then
import UIKit

final class MyPageViewController: UIViewController {
    private let tableView = UITableView().then {
        $0.register(BookCell.self, forCellReuseIdentifier: BookCell.identifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 120
        $0.separatorStyle = .none
    }

    private var savedBooks: [BookItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "담은 책"
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSavedBooks()
    }

    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func loadSavedBooks() {
        savedBooks = SavedBookManager.shared.getAll()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension MyPageViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return savedBooks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BookCell.identifier,
            for: indexPath
        ) as! BookCell
        cell.configure(with: savedBooks[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MyPageViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = savedBooks[indexPath.row]
        let detailVC = BookDetailViewController()
        detailVC.configure(with: book)
        let nav = UINavigationController(rootViewController: detailVC)
        present(nav, animated: true)
    }
}
