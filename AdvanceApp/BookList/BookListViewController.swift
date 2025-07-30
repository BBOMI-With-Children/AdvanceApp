//
//  BookListViewController.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/25/25.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class BookListViewController: UIViewController {
    private let scrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
    }
    
    private let viewModel = BookListViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        bindViewModel()
        viewModel.loadBanner()
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.height.equalTo(scrollView.frameLayoutGuide.snp.height)
        }
    }
    
    private func bindViewModel() {
        viewModel.bannerData
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] items in
                guard let self = self else { return }
                
                self.view.layoutIfNeeded()
                
                self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                
                for data in items {
                    let pageContainer = UIView()
                    self.stackView.addArrangedSubview(pageContainer)
                    
                    pageContainer.snp.makeConstraints { make in
                        make.width.equalTo(self.scrollView.frameLayoutGuide.snp.width)
                        make.height.equalTo(self.scrollView.frameLayoutGuide.snp.height)
                    }
                    
                    let banner = BannerView()
                    banner.configure(with: data)
                    pageContainer.addSubview(banner)
                    banner.snp.makeConstraints { make in
                        make.center.equalToSuperview()
                        make.width.equalTo(self.view.bounds.width - 40)
                        make.height.equalToSuperview()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

@available(iOS 17.0, *)
#Preview {
    BookListViewController()
}
