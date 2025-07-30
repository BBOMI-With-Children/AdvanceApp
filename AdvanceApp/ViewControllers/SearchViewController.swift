//
//  SearchViewController.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/29/25.
//

import UIKit
import SnapKit
import Then

class SearchViewController: UIViewController {

    private let tableView = UITableView()

    private struct BookItem {
        let image: UIImage?
        let title: String
        let author: String
        let description: String
        let price: String
    }

    private let dummyBooks: [BookItem] = [
        BookItem(
            image: UIImage(named: ""),
            title: "미움 받을 용기",
            author: "기시미 이치로",
            description: "미스터리 어드벤처 소설",
            price: "14,900원"
        ),
        BookItem(
            image: UIImage(named: ""),
            title: "아몬드",
            author: "손원평",
            description: "SF 걸작 영화",
            price: "15,000원"
        ),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
    }
}

@available(iOS 17.0, *)
#Preview {
    SearchViewController()
}
