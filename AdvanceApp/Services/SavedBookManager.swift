//
//  SavedBookManager.swift
//  AdvanceApp
//
//  Created by 노가현 on 8/1/25.
//

//
//  SavedBookManager.swift
//  AdvanceApp
//
//  Created by 노가현 on 8/1/25.
//

import CoreData
import UIKit

final class SavedBookManager {
    static let shared = SavedBookManager()
    private let context: NSManagedObjectContext

    private init() {
        // AppDelegate의 NSPersistentContainer에서 context 가져오기
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
    }

    // BookItem을 CoreData에 저장 (중복 체크)
    func save(_ book: BookItem) {
        // 같은 title + author 엔티티가 있는지 검색
        let fetchReq: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchReq.predicate = NSPredicate(
            format: "title == %@ AND author == %@",
            book.title, book.author
        )

        if let existing = (try? context.fetch(fetchReq))?.first {
            existing.createdAt = Date()
            try? context.save()
            return
        }

        let entity = BookEntity(context: context)
        entity.title = book.title
        entity.author = book.author
        entity.descriptionText = book.description
        entity.price = book.price
        entity.salePrice = book.priceText
        entity.imageURL = book.imageURL?.absoluteString
        entity.createdAt = Date()

        try? context.save()
    }

    // 저장된 책을 BookItem 배열로 반환
    func getAll() -> [BookItem] {
        let fetchReq: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchReq.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        let entities = (try? context.fetch(fetchReq)) ?? []
        return entities.map { BookItem(entity: $0) }
    }

    // CoreData의 BookEntity를 삭제
    func deleteAll() {
        let fetchReq: NSFetchRequest<NSFetchRequestResult> = BookEntity.fetchRequest()
        let deleteReq = NSBatchDeleteRequest(fetchRequest: fetchReq)

        do {
            try context.execute(deleteReq)
            try context.save()
        } catch {
            print("Failed to delete all books:", error)
        }
    }
}
