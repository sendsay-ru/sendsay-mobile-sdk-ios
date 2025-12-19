//
//  TrackSSECData.swift
//  SendsaySDK
//
//  Created by Stas ProSky on 03.09.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

public struct TrackSSECData: Codable {
    // product.*
    var productId: String?
    var productName: String?
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
    
    enum CodingKeys: String, CodingKey {
        case productId = "id"
        case productName = "name"
        case picture = "picture"
        case url = "url"
        case available = "available"
        case categoryPaths = "category_paths"
        case categoryId = "category_id"
        case category = "category"
        case description = "description"
        case vendor = "vendor"
        case model = "model"
        case type = "type"
        case price = "price"
        case oldPrice = "old_price"
        
        case email
        case updatePerItem = "update_per_item"
        case update
        
        case transactionId = "transaction_id"
        case transactionDt = "transaction_dt"
        case transactionStatus = "transaction_status"
        case transactionDiscount = "transaction_discount"
        case transactionSum = "transaction_sum"
        
        case deliveryDt = "delivery_dt"
        case deliveryPrice = "delivery_price"
        case paymentDt = "payment_dt"
        
        case items
    }
    
    public func toSsecProps() -> [String: JSONConvertible] {
        return ["ssec": (asJSONObject() as any JSONConvertible)]
    }

//    private func asDictionary() -> JSONConvertible {
//        guard let data = try? JSONEncoder().encode(self),
//              let dict = try? JSONSerialization.jsonObject(with: data) else {
//            return ["1":"1"]
//        }
//        return dict as? JSONConvertible ?? ["2":"2"]
//    }

    private func asJSONObject() -> [String: JSONValue] {
        guard
            let data = try? JSONEncoder().encode(self),
            let obj  = try? JSONSerialization.jsonObject(with: data),
            case let JSONValue.dictionary(dict)? = JSONValue(bridging: obj) // <- ключевой шаг
        else { return [:] }
        return dict
    }

    // MARK: - JSON → TrackSSECData parsing
    public enum ParseError: Error, CustomStringConvertible {
        case topLevelUnsupported
        case stringEncoding
        case notAValidJSONObject
        case serializationFailed(Error)
        case decodeFailed(Error)
        case invalidCPKeys([String])

        public var description: String {
            switch self {
                case .topLevelUnsupported: return "Top-level JSON must be a dictionary/array/JSONValue/Data/String."
                case .stringEncoding: return "String is not valid UTF-8 JSON."
                case .notAValidJSONObject: return "Object is not a valid JSON object for JSONSerialization."
                case .serializationFailed(let e): return "Failed to serialize JSON object: \(e)"
                case .decodeFailed(let e): return "Failed to decode TrackSSECData: \(e)"
                case .invalidCPKeys(let keys): return "Invalid cp keys: \(keys.joined(separator: ", "))"
            }
        }
    }

    private static func foundationObject(from json: JSONValue) -> Any {
        switch json {
        case .string(let s): return s
        case .bool(let b): return b
        case .int(let i): return i
        case .double(let d): return d
        case .decimal(let dec): return NSDecimalNumber(decimal: dec)
        case .dictionary(let dict):
            return dict.mapValues { foundationObject(from: $0) }
        case .array(let arr):
            return arr.map { foundationObject(from: $0) }
        case .null(_): return NSNull()
        }
    }

    private static func data(fromJSON json: Any) throws -> Data {
        if let data = json as? Data { return data }
        if let str = json as? String {
            guard let data = str.data(using: .utf8) else { throw ParseError.stringEncoding }
            return data
        }
        if let jv = json as? JSONValue {
            let obj = foundationObject(from: jv)
            guard JSONSerialization.isValidJSONObject(obj) else { throw ParseError.notAValidJSONObject }
            do { return try JSONSerialization.data(withJSONObject: obj, options: []) }
            catch { throw ParseError.serializationFailed(error) }
        }
        if let dict = json as? [String: Any] {
            guard JSONSerialization.isValidJSONObject(dict) else { throw ParseError.notAValidJSONObject }
            do { return try JSONSerialization.data(withJSONObject: dict, options: []) }
            catch { throw ParseError.serializationFailed(error) }
        }
        if let arr = json as? [Any] {
            guard JSONSerialization.isValidJSONObject(arr) else { throw ParseError.notAValidJSONObject }
            do { return try JSONSerialization.data(withJSONObject: arr, options: []) }
            catch { throw ParseError.serializationFailed(error) }
        }
        throw ParseError.topLevelUnsupported
    }

    /// Build `TrackSSECData` from a JSON object. Accepts `Data`, `String`, `[String: Any]`, `[Any]`, or `JSONValue`.
    public static func fromJSON(_ json: Any) throws -> TrackSSECData {
        let data = try data(fromJSON: json)
        let decoder = JSONDecoder()
        do {
            let model = try decoder.decode(TrackSSECData.self, from: data)
            try model.validate()
            return model
        } catch {
            throw ParseError.decodeFailed(error)
        }
    }

    private func validate() throws {
        if let items = self.items, !items.isEmpty {
            for item in items {
                if let cp = item.cp, !cp.isEmpty {
                    let bad = cp.keys.filter { key in
                        guard key.hasPrefix("cp") else { return true }
                        let suffix = key.dropFirst(2)
                        guard let n = Int(suffix) else { return true }
                        return !(1...20).contains(n)
                    }
                    if !bad.isEmpty { throw ParseError.invalidCPKeys(bad) }
                }
            }
        }
    }
}
