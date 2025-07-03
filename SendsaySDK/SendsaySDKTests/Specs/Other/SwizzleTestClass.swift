//
//  SwizzleTestClass.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 06/11/2019.
//  Copyright © 2019 Sendsay. All rights reserved.
//

import Foundation

class SwizzleTestClass {
    @objc dynamic func getResult() -> String {
        return "result"
    }

    @objc dynamic func getOtherResult() -> String {
        return "other result"
    }
}
