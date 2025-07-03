//
//  MockUrlOpener.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 10/01/2020.
//  Copyright © 2020 Sendsay. All rights reserved.
//

import Foundation
@testable import SendsaySDK

final class MockUrlOpener: UrlOpenerType {
    var openedBrowserLinks: [String] = []
    var openedDeeplinks: [String] = []

    func openBrowserLink(_ urlString: String) {
        openedBrowserLinks.append(urlString)
    }

    func openDeeplink(_ urlString: String) {
        openedDeeplinks.append(urlString)
    }
}
