//
//  Constants.swift
//  SendsaySDKShared
//
//  Created by Ricardo Tokashiki on 05/04/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation
import UIKit

/// enum with constants used through the SDK
public enum Constants {
    /// Network
    public enum Repository {
        public static let baseUrl = "https://mobi.sendsay.ru/xnpe/v100"
        public static let contentType = "application/json"
        public static let headerContentType = "content-type"
        public static let headerAccept = "accept"
        public static let headerContentLenght = "content-length"
        public static let headerAuthorization = "authorization"
    }

    /// Keys for plist files and userdefaults
    public enum Keys {
        public static let token = "sendsayProjectIdKey"
        public static let authorization = "sendsayAuthorization"
        public static let installTracked = "installTracked"
        public static let sessionStarted = "sessionStarted"
        public static let sessionEnded = "sessionEnded"
        public static let timeout = "sessionTimeout"
        public static let autoSessionTrack = "automaticSessionTrack"
        public static let appVersion = "CFBundleShortVersionString"
        public static let baseUrl = "sendsayBaseURL"
    }

    /// SDK Info
    public enum DeviceInfo {
        public static let osName = "iOS"
        public static let osVersion = UIDevice.current.systemVersion
        public static let sdk = "Sendsay iOS SDK"
        public static let deviceModel = UIDevice.current.model
    }

    /// Type of customer events
    public enum EventTypes {
        public static let installation = "installation"
        public static let sessionEnd = "session_end"
        public static let sessionStart = "session_start"
        public static let payment = "payment"
        public static let pushOpen = "campaign"
        public static let pushDelivered = "campaign"
        public static let campaignClick = "campaign_click"
        public static let banner = "banner"
        public static let appInbox = "campaign"
    }

    /// Error messages
    public enum ErrorMessages {
        public static let sdkNotConfigured = "Sendsay SDK isn't configured. " +
            "Before any calls to SDK functions, please configure the SDK " +
            "with Sendsay.shared.config() according to the documentation " +
            "https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/Documentation/configuration.md"
    }

    /// Success messages
    public enum SuccessMessages {
        public static let sessionStart = "Session succesfully started"
        public static let sessionEnd = "Session succesfully ended"
        static let paymentDone = "Payment was succesfully tracked!"
    }

    /// Default session values represented in seconds
    public enum Session {
        public static let defaultTimeout = 60.0
        public static let maxRetries = 5
        public static let sessionUpdateThreshold = 3.0
    }

    public enum Tracking {
        // To be able to amend session tracking with campaign data, we have to delay immediate event flushing a bit
        public static let immediateFlushDelay = 3.0
    }

    /// General constants
    public enum General {
        public static let iTunesStore = "iTunes Store"
        public static let userDefaultsSuite = "SendsaySDK"
        public static let deliveredPushUserDefaultsKey = "SENDSAY_DELIVERED_PUSH_TRACKING"
        public static let deliveredPushEventUserDefaultsKey = "SENDSAY_DELIVERED_PUSH_EVENT_TRACKING"
        public static let openedPushUserDefaultsKey = "SENDSAY_OPENED_PUSH_TRACKING"
        public static let savedCampaignClickEvent = "SENDSAY_SAVED_CAMPAIGN_CLICK"
        public static let inAppMessageDisplayStatusUserDefaultsKey = "SENDSAY_IN_APP_MESSAGE_DISPLAY_STATUS"
        public static let inAppContentBlockDisplayStatusUserDefaultsKey = "SENDSAY_IN_APP_CONTENT_BLOCK_DISPLAY_STATUS"
        public static let lastKnownConfiguration = "SENDSAY_LAST_KNOWN_CONFIGURATION"
        public static let lastKnownCustomerIds = "SENDSAY_LAST_KNOWN_CUSTOMER_IDS"
    }
}
