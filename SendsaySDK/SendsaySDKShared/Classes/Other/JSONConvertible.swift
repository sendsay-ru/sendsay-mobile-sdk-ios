//
//  JSONConvertible.swift
//  SendsaySDKShared
//
//  Created by Dominik Hadl on 23/05/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation

public protocol JSONConvertible {
    var jsonValue: JSONValue { get }
}

extension JSONValue: JSONConvertible {
    public var jsonValue: JSONValue { self }
}

extension NSString: JSONConvertible {
    public var jsonValue: JSONValue {
        return .string(self as String)
    }
}

extension String: JSONConvertible {
    public var jsonValue: JSONValue {
        return .string(self)
    }
}
extension Bool: JSONConvertible {
    public var jsonValue: JSONValue {
        return .bool(self)
    }
}

extension Int: JSONConvertible {
    public var jsonValue: JSONValue {
        return .int(self)
    }
}
extension Double: JSONConvertible {
    public var jsonValue: JSONValue {
        return .double(self)
    }
}
extension Decimal: JSONConvertible {
    public var jsonValue: JSONValue {
        return .decimal(self)
    }
}
extension NSNull: JSONConvertible {
    public var jsonValue: JSONValue {
        return .null("")
    }
}

extension Dictionary: JSONConvertible where Key == String, Value == JSONValue {
    public var jsonValue: JSONValue {
        return .dictionary(self)
    }
}

extension Array: JSONConvertible where Element == JSONValue {
    public var jsonValue: JSONValue {
        return .array(self)
    }
}

public extension JSONValue {
    init?(bridging any: Any) {
        switch any {
        case let s as String:
            self = .string(s)
        case let n as NSNumber:
            if CFGetTypeID(n) == CFBooleanGetTypeID() {
                self = .bool(n.boolValue)
            } else {
                // Попробуем сначала Int
                let intVal = n.intValue
                if NSNumber(value: intVal) == n {
                    self = .int(intVal)
                } else {
                    // Иначе кастим в Double
                    self = .double(n.doubleValue)
                }
            }
        case _ as NSNull:
            self = .null("null")
        case let a as [Any]:
            self = .array(a.compactMap { JSONValue(bridging: $0) })
        case let d as [String: Any]:
            var out: [String: JSONValue] = [:]
            for (k, v) in d { if let jv = JSONValue(bridging: v) { out[k] = jv } }
            self = .dictionary(out)
        default:
            return nil
        }
    }
}

public indirect enum JSONValue: Sendable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case decimal(Decimal)
    case dictionary([String: JSONValue])
    case array([JSONValue])
    case null(String)

    public static func convert(_ dictionary: [String: Any]) -> [String: JSONValue] {
        var result: [String: JSONValue] = [:]
        for (key, value) in dictionary {
            // swiftlint:disable force_cast
            switch value {
            case is Bool: result[key] = .bool(value as! Bool)
            case is Int: result[key] = .int(value as! Int)
            case is Decimal: result[key] = .decimal(value as! Decimal)
            case is Double: result[key] = .double(value as! Double)
            case is String: result[key] = .string(value as! String)
            case is [Any]: result[key] = .array(convert(value as! [Any]))
            case is [String: Any]: result[key] = .dictionary(convert(value as! [String: Any]))
            default:
                Sendsay.logger.log(.warning, message: "Can't convert value to JSONValue: \(value).")
                continue
            }
            // swiftlint:enable force_cast
        }
        return result
    }

    public static func convert(_ array: [Any]) -> [JSONValue] {
        var result: [JSONValue] = []
        for value in array {
            switch value {
            // swiftlint:disable force_cast
            case is Bool: result.append(.bool(value as! Bool))
            case is Int: result.append(.int(value as! Int))
            case is Double: result.append(.double(value as! Double))
            case is Decimal: result.append(.decimal(value as! Decimal))
            case is String: result.append(.string(value as! String))
            case is [Any]: result.append(.array(convert(value as! [Any])))
            case is [String: Any]: result.append(.dictionary(convert(value as! [String: Any])))
            // swiftlint:enable force_cast
            default:
                Sendsay.logger.log(.warning, message: "Can't convert value to JSONValue: \(value).")
                continue
            }
        }
        return result
    }
}

// MARK: - JSONValue literal initializers for ergonomic manual JSON
extension JSONValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) { self = .string(value) }
}

extension JSONValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) { self = .int(value) }
}

extension JSONValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) { self = .double(value) }
}

//extension JSONValue: ExpressibleByStringLiteral {
//    public init(decimalLiteral value: Decimal) { self = .string(value) }
//}

extension JSONValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) { self = .bool(value) }
}

extension JSONValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSONValue...) { self = .array(elements) }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSONValue)...) {
        self = .dictionary(Dictionary(uniqueKeysWithValues: elements))
    }
}

extension JSONValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) { self = .null("") }
}

/// Helper to upcast concrete `JSONValue` to existential `any JSONConvertible`
@inlinable public func JC(_ v: JSONValue) -> any JSONConvertible { v }

public extension JSONValue {
    var rawValue: Any {
        switch self {
        case .string(let string): return string
        case .bool(let bool): return bool
        case .int(let int): return int
        case .double(let double): return double
        case .decimal(let decimal): return decimal
        case .dictionary(let dictionary): return dictionary.mapValues { $0.rawValue }
        case .array(let array): return array.map { $0.rawValue }
        case .null(_): return NSNull()
        }
    }

    var jsonConvertible: JSONConvertible {
        switch self {
        case .string(let string): return string
        case .bool(let bool): return bool
        case .int(let int): return int
        case .double(let double): return double
        case .decimal(let decimal): return decimal
        case .dictionary(let dictionary): return dictionary
        case .array(let array): return array
        case .null(_): return NSNull()
        }
    }
}

extension JSONValue: Codable, Equatable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null("")
            return
        }

        do {
            self = .dictionary(try container.decode([String: JSONValue].self))
        } catch DecodingError.typeMismatch {
            do {
                self = .array(try container.decode([JSONValue].self))
            } catch DecodingError.typeMismatch {
                do {
                    self = .string(try container.decode(String.self))
                } catch DecodingError.typeMismatch {
                    do {
                        self = .int(try container.decode(Int.self))
                    } catch {
                        do {
                            self = .decimal(try container.decode(Decimal.self))
//                            self = .double(try container.decode(Double.self))
                        } catch {
                            self = .bool(try container.decode(Bool.self))
                        }
                    }
                }
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let int): try container.encode(int)
        case .string(let string): try container.encode(string)
        case .array(let array): try container.encode(array)
        case .bool(let bool): try container.encode(bool)
        case .double(let double): try container.encode(double)
        case .decimal(let decimal): try container.encode(decimal)
        case .dictionary(let dictionary): try container.encode(dictionary)
        case .null(_): try container.encodeNil()
        }
    }

    public static func == (_ left: JSONValue, _ right: JSONValue) -> Bool {
        switch (left, right) {
        case (.int(let int1), .int(let int2)): return int1 == int2
        case (.bool(let bool1), .bool(let bool2)): return bool1 == bool2
        case (.double(let double1), .double(let double2)): return double1 == double2
        case (.decimal(let decimal1), .decimal(let decimal2)): return decimal1 == decimal2
        case (.string(let string1), .string(let string2)): return string1 == string2
        case (.array(let array1), .array(let array2)): return array1 == array2
        case (.dictionary(let dict1), .dictionary(let dict2)): return dict1 == dict2
        case (.null(_), .null(_)): return true
        default: return false
        }
    }
}

public extension JSONValue {
    var objectValue: NSObject {
        switch self {
        case .bool(let bool): return NSNumber(value: bool)
        case .int(let int): return NSNumber(value: int)
        case .string(let string): return NSString(string: string)
        case .array(let array): return array.map({ $0.objectValue }) as NSArray
        case .double(let double): return NSNumber(value: double)
        case .decimal(let decimal): return NSDecimalNumber(decimal: decimal)
        case .dictionary(let dictionary): return dictionary.mapValues({ $0.objectValue }) as NSDictionary
        case .null(_): return NSNull()
        }
    }
}
