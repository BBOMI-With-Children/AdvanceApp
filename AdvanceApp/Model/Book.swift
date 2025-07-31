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
        let sale_price: Int
        let thumbnail: String
    }
}

struct BookItem {
    let imageURL: URL?
    let title: String
    let author: String
    let description: String
    let priceText: String

    init(document: BookSearchResponse.Document) {
        self.imageURL = URL(string: document.thumbnail)
        self.title = document.title
        self.author = document.authors.joined(separator: ", ")
        self.description = document.contents
        let price = document.sale_price > 0 ? document.sale_price : 0
        self.priceText = "\(price)원"
    }
}
