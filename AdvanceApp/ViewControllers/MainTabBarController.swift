//
//  MainTabBarController.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/29/25.
//

import UIKit

// MARK: - MainTabBarController

class MainTabBarController: UITabBarController {
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor(named: "mainColor") // 탭바 아이템 선택 색상 설정
        setupViewControllers() // 뷰 컨트롤러 설정
    }

    // MARK: - Setup

    // 탭바에 표시할 네비게이션 컨트롤러들 초기화
    private func setupViewControllers() {
        // 검색 탭
        let searchVC = SearchViewController()
        searchVC.title = "검색"
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(
            title: "검색",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass.fill")
        )

        // 마이페이지 탭
        let myPageVC = MyPageViewController()
        myPageVC.title = "마이페이지"
        let myPageNav = UINavigationController(rootViewController: myPageVC)
        myPageNav.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        myPageNav.isNavigationBarHidden = false // 마이페이지 화면에서는 네비게이션 바 표시

        // 탭바에 뷰 컨트롤러들 추가
        viewControllers = [searchNav, myPageNav]
    }
}

@available(iOS 17.0, *)
#Preview {
    MainTabBarController()
}
