//
//  ViewController.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/25/25.
//

import UIKit

class BookListViewController: UIViewController {
    private let banner = BannerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        view.addSubview(banner)
        banner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        let data = BannerViewData(
            explain: "김초엽이 그리는\n디스토피아 속 희망",
            title: "지구 끝의 온실",
            imageName: "BookImage1",
            backgroundColor: .systemPink.withAlphaComponent(0.2)
        )
        banner.configure(with: data)
    }
}

@available(iOS 17.0, *)
#Preview {
    BookListViewController()
}
