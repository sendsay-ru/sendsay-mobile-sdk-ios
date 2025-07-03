//
//  InAppContentBlockCallbackType.swift
//  SendsaySDK
//
//  Created by Adam Mihalik on 08/12/2023.
//  Copyright © 2023 Sendsay. All rights reserved.
//

import Foundation
import SafariServices

public enum InAppContentBlockType {
    case contentBlock
    case carouselContentBlock
    
    var type: String {
        switch self {
        case .carouselContentBlock:
            return "content_block_carousel"
        case .contentBlock:
            return "content_block"
        }
    }
}

public protocol InAppContentBlockCallbackType {
    func onMessageShown(placeholderId: String, contentBlock: InAppContentBlockResponse)
    func onNoMessageFound(placeholderId: String)
    func onError(placeholderId: String, contentBlock: InAppContentBlockResponse?, errorMessage: String)
    func onCloseClicked(placeholderId: String, contentBlock: InAppContentBlockResponse)
    func onActionClicked(placeholderId: String, contentBlock: InAppContentBlockResponse, action: InAppContentBlockAction)
    func onActionClickedSafari(placeholderId: String, contentBlock: InAppContentBlockResponse, action: InAppContentBlockAction)
}

internal struct DefaultInAppContentBlockCallback: InAppContentBlockCallbackType {

    func onMessageShown(placeholderId: String, contentBlock: InAppContentBlockResponse) {
        Sendsay.logger.log(
            .verbose,
            message: "Tracking of InApp Content Block \(contentBlock) show"
        )
        Sendsay.shared.trackInAppContentBlockShown(placeholderId: placeholderId, message: contentBlock)
    }

    func onNoMessageFound(placeholderId: String) {
        Sendsay.logger.log(.verbose, message: "InApp Content Block has no content for \(placeholderId)")
    }

    func onError(placeholderId: String, contentBlock: InAppContentBlockResponse?, errorMessage: String) {
        guard let contentBlock else {
            Sendsay.logger.log(.error, message: "InApp Content Block is empty!!! Nothing to track")
            return
        }
        Sendsay.logger.log(.verbose, message: "Tracking of InApp Content Block \(contentBlock.id) error")
        Sendsay.shared.trackInAppContentBlockError(
            placeholderId: placeholderId,
            message: contentBlock,
            errorMessage: errorMessage
        )
    }

    func onCloseClicked(placeholderId: String, contentBlock: InAppContentBlockResponse) {
        Sendsay.logger.log(.verbose, message: "Tracking of InApp Content Block \(contentBlock.id) close")
        Sendsay.shared.trackInAppContentBlockClose(
            placeholderId: placeholderId,
            message: contentBlock
        )
    }

    func onActionClicked(
        placeholderId: String,
        contentBlock: InAppContentBlockResponse,
        action: InAppContentBlockAction
    ) {
        Sendsay.logger.log(.verbose, message: "Tracking of InApp Content Block \(contentBlock.id) action \(action.name ?? "")")
        if action.type == .close {
            return
        }
        Sendsay.shared.trackInAppContentBlockClick(
            placeholderId: placeholderId,
            action: action,
            message: contentBlock
        )
        guard action.url != nil else {
            Sendsay.logger.log(.error, message: "InApp Content Block \(contentBlock.id) action is NIL")
            return
        }
        invokeAction(action, contentBlock)
    }

    func onActionClickedSafari(
        placeholderId: String,
        contentBlock: InAppContentBlockResponse,
        action: InAppContentBlockAction
    ) {
        Sendsay.logger.log(.verbose, message: "Tracking of InApp Content Block \(contentBlock.id) action \(action.name ?? "")")
        if action.type == .close {
            return
        }
        Sendsay.shared.trackInAppContentBlockClick(
            placeholderId: placeholderId,
            action: action,
            message: contentBlock
        )
        guard action.url != nil else {
            Sendsay.logger.log(.error, message: "InApp Content Block \(contentBlock.id) action is NIL")
            return
        }
        if action.type == .browser {
            guard let stringUrl = action.url, let url = URL(safeString: stringUrl) else { return }
            let safari = SFSafariViewController(url: url)
            UIApplication.shared.windows.first?.rootViewController?.presentedViewController?.present(safari, animated: true)
        } else {
            invokeAction(action, contentBlock)
        }
    }

    private func invokeAction(_ action: InAppContentBlockAction, _ contentBlock: InAppContentBlockResponse) {
        Sendsay.logger.log(.verbose, message: "Invoking InApp Content Block \(contentBlock.id) action '\(action.name ?? "")'")
        guard let actionUrl = action.url,
              action.type != .close else {
            return
        }
        let urlOpener = UrlOpener()
        switch action.type {
        case .deeplink:
            urlOpener.openDeeplink(actionUrl)
        case .browser:
            urlOpener.openBrowserLink(actionUrl)
        case .close:
            break
        case .unknown:
            Sendsay.logger.log(.error, message: "Invoking invalid type \(contentBlock.id) action '\(action.name ?? "")'")
        }
    }
}
