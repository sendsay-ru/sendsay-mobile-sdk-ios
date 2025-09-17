//
//  OrderItem.swift
//  SendsaySDK
//
//  Created by Stas ProSky on 03.09.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

public struct OrderItem: Codable {
    let id: String
    let qnt: Int64?
    let price: Double?
    
    let name: String?
    let description: String?
    let uniq: String?
    let available: Int64?
    let oldPrice: Double?
    let picture: [String]?
    let url: String?
    let model: String?
    let vendor: String?
    let categoryId: Int64?
    let category: String?
    
    public init(id: String, qnt: Int64? = nil, price: Double? = nil, name: String? = nil, description: String? = nil, uniq: String? = nil, available: Int64? = nil, oldPrice: Double? = nil, picture: [String]? = nil, url: String? = nil, model: String? = nil, vendor: String? = nil, categoryId: Int64? = nil, category: String? = nil) {
        self.id = id
        self.qnt = qnt
        self.price = price
        self.name = name
        self.description = description
        self.uniq = uniq
        self.available = available
        self.oldPrice = oldPrice
        self.picture = picture
        self.url = url
        self.model = model
        self.vendor = vendor
        self.categoryId = categoryId
        self.category = category
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case qnt
        case price
        case name
        case description
        case uniq
        case available
        case oldPrice = "old_price"
        case picture
        case url
        case model
        case vendor
        case categoryId = "category_id"
        case category
    }
}
