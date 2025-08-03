//
//  BookService.swift
//  AdvanceApp
//
//  Created by 노가현 on 7/31/25.
//

import Alamofire
import Foundation
import RxSwift

protocol BookServicing {
    func searchBooks(query: String, page: Int) -> Observable<[BookItem]>
}

final class BookService: BookServicing {
    static let shared = BookService()
    private init() {}

    static let pageSize = 15

    private let apiKey = "536e08fd6cae2a372119d07eb9bee824"
    private let baseURL = "https://dapi.kakao.com/v3/search/book"

    func searchBooks(query: String, page: Int) -> Observable<[BookItem]> {
        return Observable.create { observer in
            let headers: HTTPHeaders = ["Authorization": "KakaoAK \(self.apiKey)"]
            let parameters: Parameters = [
                "query": query,
                "page": page,
                "size": BookService.pageSize
                ]
            let request = AF.request(
                self.baseURL,
                parameters: parameters,
                headers: headers
            )
            .validate()
            .responseDecodable(of: BookSearchResponse.self) { resp in
                switch resp.result {
                case .success(let data):
                    let items = data.documents.map(BookItem.init)
                    observer.onNext(items)
                case .failure(let err):
                    observer.onError(err)
                }
                observer.onCompleted()
            }
            return Disposables.create { request.cancel() }
        }
    }
}
