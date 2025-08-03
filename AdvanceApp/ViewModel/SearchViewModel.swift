//
//  SearchViewModel.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/30/25.
//

import Foundation
import RxCocoa
import RxSwift

struct SearchInput {
    let queryText: Observable<String>
    let loadNextPage: Observable<Void>
}

struct SearchOutput {
    let books: Driver<[BookItem]>
}

protocol SearchViewModeling {
    func transform(_ input: SearchInput) -> SearchOutput
}

final class SearchViewModel: SearchViewModeling {
    private let service: BookServicing
    private let disposeBag = DisposeBag()

    init(service: BookServicing = BookService.shared) {
        self.service = service
    }

    func transform(_ input: SearchInput) -> SearchOutput {
        let books = input.queryText
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .flatMapLatest { [service] text in
                service.searchBooks(query: text)
                    .catchAndReturn([])
            }
            .asDriver(onErrorJustReturn: [])

        return SearchOutput(books: books)
    }
}
