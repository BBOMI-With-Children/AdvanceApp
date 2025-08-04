//
//  MyPageViewModel.swift
//  AdvanceApp
//
//  Created by 노가현 on 8/3/25.
//

import RxCocoa
import RxSwift

final class MyPageViewModel {
    private let savedBooksRelay = BehaviorRelay<[BookItem]>(value: [])
    private let disposeBag = DisposeBag()

    var books: Driver<[BookItem]> {
        savedBooksRelay
            .asDriver(onErrorJustReturn: [])
    }

    var isEmpty: Driver<Bool> {
        books
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: true)
    }

    func loadBooks() {
        let books = SavedBookManager.shared.getAll()
        savedBooksRelay.accept(books)
    }

    func deleteAll() {
        SavedBookManager.shared.deleteAll()
        savedBooksRelay.accept([])
    }
}
