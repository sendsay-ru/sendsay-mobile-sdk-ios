//
//  AnyCodable.swift
//  SendsaySDK
//
//  Created by Stas ProSky on 03.09.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

public struct AnyCodable: Codable, Equatable, CustomStringConvertible {
    public enum Storage: Equatable {
        case null
        case bool(Bool)
        case int(Int64)
        case double(Double)
        case string(String)
        case array([AnyCodable])
        case dictionary([String: AnyCodable])
    }

    public var storage: Storage
    public init(_ value: Storage) { self.storage = value }

    // MARK: - Convenient inits
    public init(_ value: Any?) {
        switch value {
        case nil: self.storage = .null
        case let v as Bool: self.storage = .bool(v)
        case let v as Int: self.storage = .int(Int64(v))
        case let v as Int64: self.storage = .int(v)
        case let v as Double: self.storage = .double(v)
        case let v as Float: self.storage = .double(Double(v))
        case let v as String: self.storage = .string(v)
        case let v as [Any?]:
            self.storage = .array(v.map { AnyCodable($0) })
        case let v as [String: Any?]:
            var dict: [String: AnyCodable] = [:]
            for (k, val) in v { dict[k] = AnyCodable(val) }
            self.storage = .dictionary(dict)
        default:
            // Для неподдерживаемых типов пытаемся через JSONSerialization (может не сработать)
            if let d = try? JSONSerialization.data(withJSONObject: value ?? NSNull()),
               let decoded = try? JSONDecoder().decode(AnyCodable.self, from: d) {
                self = decoded
            } else {
                self.storage = .null
            }
        }
    }

    // MARK: - Codable
    public init(from decoder: Decoder) throws {
        // Пробуем singleValue
        let single = try? decoder.singleValueContainer()
        if let c = single {
            if c.decodeNil() { self.storage = .null; return }
            if let b = try? c.decode(Bool.self) { self.storage = .bool(b); return }
            if let i = try? c.decode(Int64.self) { self.storage = .int(i); return }
            if let d = try? c.decode(Double.self) { self.storage = .double(d); return }
            if let s = try? c.decode(String.self) { self.storage = .string(s); return }
        }

        // Пробуем массив
        if var unkeyed = try? decoder.unkeyedContainer() {
            var arr: [AnyCodable] = []
            while !unkeyed.isAtEnd {
                let v = try unkeyed.decode(AnyCodable.self)
                arr.append(v)
            }
            self.storage = .array(arr)
            return
        }

        // Пробуем словарь
        if let keyed = try? decoder.container(keyedBy: AnyCodingKey.self) {
            var dict: [String: AnyCodable] = [:]
            for key in keyed.allKeys {
                let v = try keyed.decode(AnyCodable.self, forKey: key)
                dict[key.stringValue] = v
            }
            self.storage = .dictionary(dict)
            return
        }

        // Фоллбек
        self.storage = .null
    }

    public func encode(to encoder: Encoder) throws {
        switch storage {
        case .null:
            var c = encoder.singleValueContainer()
            try c.encodeNil()
        case .bool(let b):
            var c = encoder.singleValueContainer()
            try c.encode(b)
        case .int(let i):
            var c = encoder.singleValueContainer()
            try c.encode(i)
        case .double(let d):
            var c = encoder.singleValueContainer()
            try c.encode(d)
        case .string(let s):
            var c = encoder.singleValueContainer()
            try c.encode(s)
        case .array(let arr):
            var c = encoder.unkeyedContainer()
            for v in arr { try c.encode(v) }
        case .dictionary(let dict):
            var c = encoder.container(keyedBy: AnyCodingKey.self)
            for (k, v) in dict { try c.encode(v, forKey: AnyCodingKey(stringValue: k)) }
        }
    }

    // MARK: - Helpers
    public var value: Any {
        switch storage {
        case .null: return NSNull()
        case .bool(let b): return b
        case .int(let i): return i
        case .double(let d): return d
        case .string(let s): return s
        case .array(let a): return a.map { $0.value }
        case .dictionary(let d): return d.mapValues { $0.value }
        }
    }

    public var description: String {
        switch storage {
        case .null: return "null"
        case .bool(let b): return b.description
        case .int(let i): return i.description
        case .double(let d): return d.description
        case .string(let s): return "\"\(s)\""
        case .array(let a): return "[\(a.map(\.description).joined(separator: ", "))]"
        case .dictionary(let d):
            let body = d.map { "\"\($0)\": \($1.description)" }.sorted().joined(separator: ", ")
            return "{\(body)}"
        }
    }
}

public struct AnyCodingKey: CodingKey {
    public var stringValue: String
    public var intValue: Int? { nil }
    public init(stringValue: String) { self.stringValue = stringValue }
    public init?(intValue: Int) { return nil }
}
