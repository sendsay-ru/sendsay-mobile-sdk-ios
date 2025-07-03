//
//  TrackingObject.swift
//  SendsaySDKShared
//
//  Created by Panaxeo on 05/03/2020.
//  Copyright © 2020 Sendsay. All rights reserved.
//

import Foundation

public protocol TrackingObject {
    var sendsayProject: SendsayProject { get }
    var customerIds: [String: String] { get }
    var dataTypes: [DataType] { get }
    var timestamp: Double { get }
}

public final class EventTrackingObject: TrackingObject, Equatable, Codable {
    public let sendsayProject: SendsayProject
    public let customerIds: [String: String]
    public let eventType: String?
    public let timestamp: Double
    public let dataTypes: [DataType]

    public init(
        sendsayProject: SendsayProject,
        customerIds: [String: String],
        eventType: String?,
        timestamp: Double,
        dataTypes: [DataType]
    ) {
        self.sendsayProject = sendsayProject
        self.customerIds = customerIds
        self.eventType = eventType
        self.timestamp = timestamp
        self.dataTypes = dataTypes
    }

    public static func == (lhs: EventTrackingObject, rhs: EventTrackingObject) -> Bool {
        return lhs.sendsayProject == rhs.sendsayProject
            && lhs.customerIds == rhs.customerIds
            && lhs.eventType == rhs.eventType
            && lhs.timestamp == rhs.timestamp
            && lhs.dataTypes == rhs.dataTypes
    }
    
    public static func deserialize(from data: Data) -> EventTrackingObject? {
        return try? JSONDecoder.snakeCase.decode(EventTrackingObject.self, from: data)
    }

    public func serialize() -> Data? {
        return try? JSONEncoder.snakeCase.encode(self)
    }
}

public final class CustomerTrackingObject: TrackingObject {
    public let sendsayProject: SendsayProject
    public let customerIds: [String: String]
    public let timestamp: Double
    public let dataTypes: [DataType]

    public init(
        sendsayProject: SendsayProject,
        customerIds: [String: String],
        timestamp: Double,
        dataTypes: [DataType]
    ) {
        self.sendsayProject = sendsayProject
        self.customerIds = customerIds
        self.timestamp = timestamp
        self.dataTypes = dataTypes
    }
}

public extension TrackingObject {
    static func loadCustomerIdsFromUserDefaults(appGroup: String) -> [String: String]? {
        guard let userDefaults = UserDefaults(suiteName: appGroup),
              let data = userDefaults.data(forKey: Constants.General.lastKnownCustomerIds) else {
            return nil
        }
        return try? JSONDecoder().decode([String: String].self, from: data)
    }
}
