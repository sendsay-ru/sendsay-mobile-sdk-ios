//
//  OrderItem.swift
//  SendsaySDK
//
//  Created by Stas ProSky on 03.09.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

public struct OrderItem: Codable {
    public let id: String
    public let qnt: Int64?
    public let price: Double?
    
    public let name: String?
    public let description: String?
    public let uniq: String?
    public let available: Int64?
    public let oldPrice: Double?
    public let picture: [String]?
    public let url: String?
    public let model: String?
    public let vendor: String?
    public let categoryId: Int64?
    public let category: String?
    
    /// Custom properties cp1..cp20 encoded flat at the same level as the item
    public var cp: [String: AnyCodable]?
    
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
    
    public init(id: String, qnt: Int64? = nil, price: Double? = nil, name: String? = nil, description: String? = nil, uniq: String? = nil, available: Int64? = nil, oldPrice: Double? = nil, picture: [String]? = nil, url: String? = nil, model: String? = nil, vendor: String? = nil, categoryId: Int64? = nil, category: String? = nil, cp: [String: AnyCodable]? = nil) {
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
        self.cp = cp
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
    
    private struct AnyKey: CodingKey {
        var stringValue: String
        var intValue: Int?
        init(stringValue: String) { self.stringValue = stringValue; self.intValue = nil }
        init?(intValue: Int) { self.stringValue = "\(intValue)"; self.intValue = intValue }
    }
}

public extension OrderItem {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AnyKey.self)
        // encode standard fields
        if let qnt = qnt { try container.encode(qnt, forKey: AnyKey(stringValue: CodingKeys.qnt.rawValue)) }
        if let price = price { try container.encode(price, forKey: AnyKey(stringValue: CodingKeys.price.rawValue)) }
        try container.encode(id, forKey: AnyKey(stringValue: CodingKeys.id.rawValue))
        if let name = name { try container.encode(name, forKey: AnyKey(stringValue: CodingKeys.name.rawValue)) }
        if let description = description { try container.encode(description, forKey: AnyKey(stringValue: CodingKeys.description.rawValue)) }
        if let uniq = uniq { try container.encode(uniq, forKey: AnyKey(stringValue: CodingKeys.uniq.rawValue)) }
        if let available = available { try container.encode(available, forKey: AnyKey(stringValue: CodingKeys.available.rawValue)) }
        if let oldPrice = oldPrice { try container.encode(oldPrice, forKey: AnyKey(stringValue: CodingKeys.oldPrice.rawValue)) }
        if let picture = picture { try container.encode(picture, forKey: AnyKey(stringValue: CodingKeys.picture.rawValue)) }
        if let url = url { try container.encode(url, forKey: AnyKey(stringValue: CodingKeys.url.rawValue)) }
        if let model = model { try container.encode(model, forKey: AnyKey(stringValue: CodingKeys.model.rawValue)) }
        if let vendor = vendor { try container.encode(vendor, forKey: AnyKey(stringValue: CodingKeys.vendor.rawValue)) }
        if let categoryId = categoryId { try container.encode(categoryId, forKey: AnyKey(stringValue: CodingKeys.categoryId.rawValue)) }
        if let category = category { try container.encode(category, forKey: AnyKey(stringValue: CodingKeys.category.rawValue)) }
        // encode cp1..cp20 at top level
        if let cp = cp {
            for (k, v) in cp {
                guard k.hasPrefix("cp"), let idx = Int(k.dropFirst(2)), (1...20).contains(idx) else { continue }
                try container.encode(v, forKey: AnyKey(stringValue: k))
            }
        }
    }
}

public extension OrderItem {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyKey.self)
        self.id = try container.decode(String.self, forKey: AnyKey(stringValue: CodingKeys.id.rawValue))
        self.qnt = try container.decodeIfPresent(Int64.self, forKey: AnyKey(stringValue: CodingKeys.qnt.rawValue))
        self.price = try container.decodeIfPresent(Double.self, forKey: AnyKey(stringValue: CodingKeys.price.rawValue))
        self.name = try container.decodeIfPresent(String.self, forKey: AnyKey(stringValue: CodingKeys.name.rawValue))
        self.description = try container.decodeIfPresent(String.self, forKey: AnyKey(stringValue: CodingKeys.description.rawValue))
        self.uniq = try container.decodeIfPresent(String.self, forKey: AnyKey(stringValue: CodingKeys.uniq.rawValue))
        self.available = try container.decodeIfPresent(Int64.self, forKey: AnyKey(stringValue: CodingKeys.available.rawValue))
        self.oldPrice = try container.decodeIfPresent(Double.self, forKey: AnyKey(stringValue: CodingKeys.oldPrice.rawValue))
        self.picture = try container.decodeIfPresent([String].self, forKey: AnyKey(stringValue: CodingKeys.picture.rawValue))
        self.url = try container.decodeIfPresent(String.self, forKey: AnyKey(stringValue: CodingKeys.url.rawValue))
        self.model = try container.decodeIfPresent(String.self, forKey: AnyKey(stringValue: CodingKeys.model.rawValue))
        self.vendor = try container.decodeIfPresent(String.self, forKey: AnyKey(stringValue: CodingKeys.vendor.rawValue))
        self.categoryId = try container.decodeIfPresent(Int64.self, forKey: AnyKey(stringValue: CodingKeys.categoryId.rawValue))
        self.category = try container.decodeIfPresent(String.self, forKey: AnyKey(stringValue: CodingKeys.category.rawValue))
        // collect cp1..cp20
        var cpDict: [String: AnyCodable] = [:]
        for i in 1...20 {
            let key = "cp\(i)"
            if let value = try container.decodeIfPresent(AnyCodable.self, forKey: AnyKey(stringValue: key)) {
                cpDict[key] = value
            }
        }
        self.cp = cpDict.isEmpty ? nil : cpDict
    }
}
