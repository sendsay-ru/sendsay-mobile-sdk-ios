//
//  SwizzleSpec.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 06/11/2019.
//  Copyright © 2019 Sendsay. All rights reserved.
//

import Nimble
import Quick

@testable import SendsaySDK

final class SwizzleSpec: QuickSpec {
    override func spec() {
        it("should get description of swizzle") {
            let testClass = type(of: SwizzleTestClass())
            let selector = #selector(SwizzleTestClass.getResult)
            let swizzle = Swizzle(
                block: { _, _, _ in },
                name: "test swizzle",
                aClass: testClass,
                selector: selector,
                originalMethod: method_getImplementation(class_getInstanceMethod(testClass, selector)!)
            )
            expect(swizzle.description).to(
                equal("Swizzle on SendsaySDKTests.SwizzleTestClass::getResult [test swizzle,]")
            )
        }
    }
}
