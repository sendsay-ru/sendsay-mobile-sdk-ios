//
//  TrackSSECData.swift
//  SendsaySDK
//
//  Created by Stas ProSky on 03.09.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

struct TrackSSECData: Codable {
    // product.*
    var productId: String?
    var productName: String?
    var dateTime: String?
    var picture: [String]?
    var url: String?
    var available: Int64?
    var categoryPaths: [String]?
    var categoryId: Int64?
    var category: String?
    var description: String?
    var vendor: String?
    var model: String?
    var type: String?
    var price: Double?
    var oldPrice: Double?
    
    // other
    var email: String?
    var updatePerItem: Int64?
    var update: Int64?
    
    // transaction.*
    var transactionId: String?
    var transactionDt: String?
    var transactionStatus: Int64?
    var transactionDiscount: Double?
    var transactionSum: Double?
    
    // delivery & payment
    var deliveryDt: String?
    var deliveryPrice: Double?
    var paymentDt: String?
    
    // items
    var items: [OrderItem]?
    
    // cp1..cp20
    var cp: [String: AnyCodable]?
    
    
    // Пример заполнения cp:
//    func payload() -> TrackSSECData {
//        return TrackSSECData(
//            // ...
//            cp: [
//                "cp1": AnyCodable(.string("foo")),
//                "cp2": AnyCodable(.int(42)),
//                "cp3": AnyCodable(.double(3.14)),
//                "cp4": AnyCodable(.array([AnyCodable(.bool(true)), AnyCodable(.null)]))
//            ]
//        )
//    }
    
    enum CodingKeys: String, CodingKey {
        case productId = "product.id"
        case productName = "product.name"
        case dateTime = "dt"
        case picture = "product.picture"
        case url = "product.url"
        case available = "product.available"
        case categoryPaths = "product.category_paths"
        case categoryId = "product.category_id"
        case category = "product.category"
        case description = "product.description"
        case vendor = "product.vendor"
        case model = "product.model"
        case type = "product.type"
        case price = "product.price"
        case oldPrice = "product.old_price"
        
        case email
        case updatePerItem = "update_per_item"
        case update
        
        case transactionId = "transaction.id"
        case transactionDt = "transaction.dt"
        case transactionStatus = "transaction.status"
        case transactionDiscount = "transaction.discount"
        case transactionSum = "transaction.sum"
        
        case deliveryDt = "delivery.dt"
        case deliveryPrice = "delivery.price"
        case paymentDt = "payment.dt"
        
        case items
        case cp
    }
    
    /// Пример конверсии в словарь
//    func toDictionary() -> [String: Any] {
//        return ["ssec": self.asDictionary()]
//    }
    
    private func asDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return dict
    }
}

