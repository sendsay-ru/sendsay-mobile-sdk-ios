//
//  MockUserDefaults.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 06/09/2019.
//  Copyright © 2019 Sendsay. All rights reserved.
//

import Foundation

class MockUserDefaults: UserDefaults {

    convenience init() {
        self.init(suiteName: "Mock User Defaults")!
    }

    override init?(suiteName suitename: String?) {
        UserDefaults().removePersistentDomain(forName: suitename!)
        super.init(suiteName: suitename)
    }
}
