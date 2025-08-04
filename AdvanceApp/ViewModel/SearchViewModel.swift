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

    // MARK: - Paging State

    private var currentPage = 1
    private var isEnd = false
    private var currentQuery = ""

    private let itemsRelay = BehaviorRelay<[BookItem]>(value: [])

    init(service: BookServicing = BookService.shared) {
        self.service = service
    }

    func transform(_ input: SearchInput) -> SearchOutput {
        // 1) queryText 변경 -> 상태 초기화 & 첫 페이지 요청
        let newSearch = input.queryText
            .filter { !$0.isEmpty }
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .do(onNext: { [weak self] q in
                guard let self = self else { return }
                self.currentQuery = q
                self.currentPage = 1
                self.isEnd = false
                self.itemsRelay.accept([])
            })
            .flatMapLatest { [service] q in
                service.searchBooks(query: q, page: 1)
            }

        // 2) 페이지 증가 & 요청 (끝이 아니면)
        let nextPage = input.loadNextPage
            .filter { [weak self] in !(self?.isEnd ?? true) }
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] _ -> Observable<BookSearchResponse> in
                guard let self = self else { return .empty() }
                self.currentPage += 1
                return self.service.searchBooks(query: self.currentQuery, page: self.currentPage)
            }

        // 3) itemsRelay 누적, isEnd 플래그 업데이트
        Observable
            .merge(newSearch, nextPage)
            .observe(on: MainScheduler.instance)
            .do(onNext: { response in
                print("page:", self.currentPage,
                      "docs:", response.documents.count,
                      "is_end:", response.meta.is_end)
            })
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                let newItems = response.documents.map(BookItem.init)
                let allItems = self.itemsRelay.value + newItems
                self.itemsRelay.accept(allItems)
                self.isEnd = response.meta.is_end
            })
            .disposed(by: disposeBag)

        // 4) 결과 Driver로 반환
        return SearchOutput(
            books: itemsRelay
                .asDriver(onErrorDriveWith: .empty())
        )
    }
}
