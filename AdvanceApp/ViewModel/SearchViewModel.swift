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

    private var currentPage = 1
    private var isEnd = false
    private var currentQuery = ""
    private let items = BehaviorRelay<[BookItem]>(value: [])

    init(service: BookServicing = BookService.shared) {
        self.service = service
    }

    func transform(_ input: SearchInput) -> SearchOutput {
        input.queryText
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .do(onNext: { q in
                self.currentQuery = q
                self.currentPage = 1
                self.isEnd = false
                self.items.accept([])
            })
            .flatMapLatest { q in
                self.service.searchBooks(query: q, page: self.currentPage)
                    .catchAndReturn([])
            }
            .subscribe(onNext: { list in
                self.items.accept(list)
                self.isEnd = list.count < BookService.pageSize
            })
            .disposed(by: disposeBag)

        // 2) 마지막 셀 표시될 때마다 다음 페이지 로드
        input.loadNextPage
            .filter { !self.isEnd }
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .flatMapLatest { _ -> Observable<[BookItem]> in
                self.currentPage += 1
                return self.service.searchBooks(query: self.currentQuery,
                                                page: self.currentPage)
                .catchAndReturn([])
            }
            .subscribe(onNext: { more in
                self.items.accept(self.items.value + more)
                self.isEnd = more.count < BookService.pageSize
            })
            .disposed(by: disposeBag)

        // 3) 최종 Output
        return SearchOutput(
            books: items.asDriver(onErrorDriveWith: .empty())
        )
    }
}
