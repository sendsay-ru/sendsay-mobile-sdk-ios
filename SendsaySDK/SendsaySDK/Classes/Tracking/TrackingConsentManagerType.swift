//
//  TrackingConsentManagerType.swift
//  SendsaySDK
//
//  Created by Adam Mihalik on 23/09/2022.
//  Copyright © 2022 Sendsay. All rights reserved.
//

import Foundation

protocol TrackingConsentManagerType {
    func trackInAppMessageClick(message: InAppMessage, buttonText: String?, buttonLink: String?, mode: MODE, isUserInteraction: Bool)
    func trackInAppMessageClose(message: InAppMessage, buttonText: String?, mode: MODE, isUserInteraction: Bool)
    func trackInAppMessageShown(message: InAppMessage, mode: MODE)
    func trackInAppMessageError(message: InAppMessage, error: String, mode: MODE)
    func trackClickedPush(data: AnyObject?, mode: MODE)
    func trackClickedPush(data: PushOpenedData)
    func trackDeliveredPush(data: NotificationData, mode: MODE)
    func trackAppInboxClick(message: MessageItem, buttonText: String?, buttonLink: String?, mode: MODE)
    func trackAppInboxOpened(message: MessageItem, mode: MODE)
    func trackInAppContentBlockClick(
        placeholderId: String,
        message: InAppContentBlockResponse,
        action: InAppContentBlockAction,
        mode: MODE
    )
    func trackInAppContentBlockClose(placeholderId: String, message: InAppContentBlockResponse, mode: MODE)
    func trackInAppContentBlockShow(placeholderId: String, message: InAppContentBlockResponse, mode: MODE)
    func trackInAppContentBlockError(
        placeholderId: String,
        message: InAppContentBlockResponse,
        errorMessage: String,
        mode: MODE
    )
//    func trackSSEC(message: MessageItem, mode: MODE)
}

enum MODE {
    case CONSIDER_CONSENT
    case IGNORE_CONSENT
}

public enum TrackingSSECType: String, CaseIterable {
    case viewProduct = "ssec_product_view"
    case order = "ssec_order"
    case viewCategory = "ssec_category_view"
    case basketAdd = "ssec_basket"
    case basketClear = "ssec_basket_clear"
    case searchProduct = "ssec_product_search"
    case subscribeProductPrice = "ssec_product_price"
    case subscribeProductIsa = "ssec_subscribe_product_isa"
    case favorite = "ssec_product_favorite"
    case preorder = "ssec_product_preorder"
    case productIsa = "ssec_product_isa"
    case productPriceChanged = "ssec_product_price_chang"
    case registration = "ssec_registration"
    case authorization = "ssec_authorization"
    
    static func find(value: String?) -> TrackingSSECType? {
        guard let value = value else { return nil }
        return TrackingSSECType.allCases.first { $0.rawValue.caseInsensitiveCompare(value) == .orderedSame }
    }
}
