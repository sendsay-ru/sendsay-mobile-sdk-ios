//
//  OrderItem.swift
//  SendsaySDK
//
//  Created by Stas ProSky on 03.09.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

struct OrderItem: Codable {
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
