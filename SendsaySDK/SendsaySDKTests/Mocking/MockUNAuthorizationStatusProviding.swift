//
//  MockUNAuthorizationStatusProviding.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 11/03/2020.
//  Copyright © 2020 Sendsay. All rights reserved.
//

@testable import SendsaySDK

class MockUNAuthorizationStatusProviding: UNAuthorizationStatusProviding {
    private let status: UNAuthorizationStatus

    init(status: UNAuthorizationStatus) {
        self.status = status
    }

    func isAuthorized(completion: @escaping (Bool) -> Void) {
        completion(status.rawValue == UNAuthorizationStatus.authorized.rawValue)
    }
}
