//
//  BuildConfiguration.swift
//  SendsaySDK
//
//  Created by Panaxeo on 24/02/2020.
//  Copyright © 2020 Sendsay. All rights reserved.
//

import Foundation

func isReactNativeSDK() -> Bool {
    // Our react native SDK contains a protocol IsSendsayReactNativeSDK. We only use it for this purpose.
    return NSProtocolFromString("IsSendsayReactNativeSDK") != nil
}

func isCapacitorSDK() -> Bool {
    // Our Capacitor SDK contains a protocol IsSendsayCapacitorSDK. We only use it for this purpose.
    return NSProtocolFromString("IsSendsayCapacitorSDK") != nil
}

func isFlutterSDK() -> Bool {
    // Our flutter SDK contains a protocol IsSendsayFlutterSDK. We only use it for this purpose.
    return NSProtocolFromString("IsSendsayFlutterSDK") != nil
}

func isXamarinSDK() -> Bool {
    // Our Xamarin SDK contains a protocol IsSendsayFlutterSDK. We only use it for this purpose.
    return NSProtocolFromString("IsSendsayXamarinSDK") != nil
}

func isMauiSDK() -> Bool {
    NSProtocolFromString("IsBloomreachMauiSDK") != nil
}

func isCalledFromExampleApp() -> Bool {
    return NSProtocolFromString("IsSendsayExampleApp") != nil
}

func isCalledFromSDKTests() -> Bool {
    return NSProtocolFromString("IsSendsaySDKTest") != nil
}

func getReactNativeSDKVersion() -> String? {
    getVersionFromClass("SendsayRNVersion")
}

func getFlutterSDKVersion() -> String? {
    getVersionFromClass("SendsayFlutterVersion")
}

func getXamarinSDKVersion() -> String? {
    getVersionFromClass("SendsayXamarinVersion")
}

func getMauiVersion() -> String? {
    getVersionFromClass("BloomreachMauiVersion")
}

private func getVersionFromClass(_ className: String) -> String? {
    guard let foundClass = NSClassFromString(className) else {
        Sendsay.logger.log(.error, message: "Missing '\(className)' class")
        return nil
    }
    guard let asNSObjectClass = foundClass as? NSObject.Type else {
        Sendsay.logger.log(.error, message: "Class '\(className)' does not conform to NSObject")
        return nil
    }
    guard let asProviderClass = asNSObjectClass as? SendsayVersionProvider.Type else {
        Sendsay.logger.log(.error, message: "Class '\(className)' does not conform to SendsayVersionProvider")
        return nil
    }
    let providerInstance = asProviderClass.init()
    Sendsay.logger.log(.verbose, message: "Version provider \(className) has been found")
    return providerInstance.getVersion()
}
