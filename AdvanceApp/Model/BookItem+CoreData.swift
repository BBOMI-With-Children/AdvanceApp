//
//  BookItem+CoreData.swift
//  AdvanceApp
//
//  Created by 노가현 on 8/1/25.
//

import Foundation
import CoreData

extension BookItem {
    init(entity: BookEntity) {
        self.title       = entity.title         ?? ""
        self.author      = entity.author        ?? ""
        self.description = entity.descriptionText ?? ""
        self.price       = entity.price         ?? ""
        self.priceText   = entity.salePrice     ?? ""
        self.imageURL    = URL(string: entity.imageURL ?? "")
    }
}
