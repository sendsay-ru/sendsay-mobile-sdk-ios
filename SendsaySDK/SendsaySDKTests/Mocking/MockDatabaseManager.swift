//
//  MockDatabase.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 11/04/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation
import CoreData

@testable import SendsaySDK

class MockDatabaseManager: DatabaseManager {
    init() throws {
        let inMemoryDescription = NSPersistentStoreDescription()
        inMemoryDescription.type = NSInMemoryStoreType
        try super.init(persistentStoreDescriptions: [inMemoryDescription])
    }
}
