//
//  BookItem+CoreData.swift
//  AdvanceApp
//
//  Created by 노가현 on 8/1/25.
//

import CoreData
import Foundation

extension BookItem {
    init(entity: BookEntity) {
        self.title = entity.title ?? ""
        self.author = entity.author ?? ""
        self.description = entity.descriptionText ?? ""

        // CoreData에 저장된 문자열("1,000원" 등)에서 숫자만 추출해 Int 변환
        let rawPriceString = entity.price?
            .filter { $0.isNumber } ?? ""
        let rawPrice = Int(rawPriceString) ?? 0

        // 천 단위 콤마 포맷팅
        let formattedPrice = BookItem.priceFormatter
            .string(from: NSNumber(value: rawPrice)) ?? "\(rawPrice)"
        self.price = "\(formattedPrice)원"

        // 판매가(할인가)도 동일하게 처리
        let rawSaleString = entity.salePrice?
            .filter { $0.isNumber } ?? ""
        let rawSale = Int(rawSaleString) ?? 0
        let saleValue = rawSale > 0 ? rawSale : rawPrice

        let formattedSale = BookItem.priceFormatter
            .string(from: NSNumber(value: saleValue)) ?? "\(saleValue)"
        self.priceText = "\(formattedSale)원"

        self.imageURL = URL(string: entity.imageURL ?? "")
    }
}
