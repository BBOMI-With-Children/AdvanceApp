//
//  SavedBookManager.swift
//  AdvanceApp
//
//  Created by 노가현 on 8/1/25.
//

import Foundation

final class SavedBookManager {
    static let shared = SavedBookManager()
    private init() {}

    private var books: [BookItem] = []

    func save(_ book: BookItem) {
        if !books.contains(where: { $0.title == book.title && $0.author == book.author }) {
            books.append(book)
        }
    }

    func getAll() -> [BookItem] {
        return books
    }
}
