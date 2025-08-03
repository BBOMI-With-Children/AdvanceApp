//
//  Book.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/31/25.
//

import Foundation

struct BookSearchResponse: Codable {
    let documents: [Document]
    struct Document: Codable {
        let title: String
        let authors: [String]
        let contents: String
        let price: Int
        let sale_price: Int
        let thumbnail: String
    }
}

struct BookItem {
    let imageURL: URL?
    let title: String
    let author: String
    let description: String
    let price: String
    let priceText: String

    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()

    init(document: BookSearchResponse.Document) {
        self.imageURL = URL(string: document.thumbnail)
        self.title = document.title
        self.author = document.authors.joined(separator: ", ")
        self.description = document.contents

        // 원가 포맷팅
        let formattedPrice = BookItem.priceFormatter
            .string(from: NSNumber(value: document.price))
            ?? "\(document.price)"
        self.price = "\(formattedPrice)원"

        // 판매가(할인가) 포맷팅: sale_price가 0 이하일 땐 원가 사용
        let saleValue = document.sale_price > 0
            ? document.sale_price
            : document.price
        let formattedSale = BookItem.priceFormatter
            .string(from: NSNumber(value: saleValue))
            ?? "\(saleValue)"
        self.priceText = "\(formattedSale)원"
    }
}
