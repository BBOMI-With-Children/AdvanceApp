//
//  BannerViewModel.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/31/25.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

final class BannerViewModel {
    let bannerData = BehaviorRelay<[BannerViewData]>(value: [])

    func loadBanner() {
        let items: [BannerViewData] = [
            BannerViewData(
                explain: "김초엽이 그리는\n디스토피아 속 희망",
                title: "지구 끝의 온실",
                imageName: "BookImage1",
                backgroundColor: .systemPink.withAlphaComponent(0.2)
            ),
            BannerViewData(
                explain: "회복과 연민에 대한\n강력한 이야기",
                title: "파친코",
                imageName: "BookImage2",
                backgroundColor: .systemOrange.withAlphaComponent(0.2)
            ),
            BannerViewData(
                explain: "포기하는 게 무섭지,\n못하는 건 두렵지 않다!",
                title: "인생을 키우는 기술",
                imageName: "BookImage3",
                backgroundColor: .systemBlue.withAlphaComponent(0.2)
            )
        ]
        // bannerData.accept(items)
        bannerData.accept(Array(items.prefix(1)))
    }
}
