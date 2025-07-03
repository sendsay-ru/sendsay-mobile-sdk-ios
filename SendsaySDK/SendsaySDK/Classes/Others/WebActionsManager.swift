//
//  WebActionsManager.swift
//  SendsaySDK
//
//  Created by Adam Mihalik on 11/01/2023.
//  Copyright © 2023 Sendsay. All rights reserved.
//

import Foundation
import WebKit

final class WebActionManager: NSObject, WKNavigationDelegate {
    
    // MARK: - Properties
    
    var htmlPayload: NormalizedResult?
    
    private var onCloseCallback: ((ActionInfo?) -> Void)?
    private var onActionCallback: ((ActionInfo) -> Void)?
    private var onErrorCallback: ((SendsayError) -> Void)?
    private var onActionTypeCallback: ((String) -> Void)?
    
    // MARK: - Init
    
    init(
        onCloseCallback: ((ActionInfo?) -> Void)? = nil,
        onActionCallback: ((ActionInfo) -> Void)? = nil,
        onErrorCallback: ((SendsayError) -> Void)? = nil
    ) {
        self.onCloseCallback = onCloseCallback
        self.onActionCallback = onActionCallback
        self.onErrorCallback = onErrorCallback
    }
    
    // MARK: - Methods
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        let handled = handleActionClick(navigationAction.request.url)
        if handled {
            Sendsay.logger.log(.verbose, message: "[HTML] Action \(navigationAction.request.url?.absoluteString ?? "Invalid") has been handled")
            decisionHandler(.cancel)
        } else {
            Sendsay.logger.log(.verbose, message: "[HTML] Action \(navigationAction.request.url?.absoluteString ?? "Invalid") has not been handled, continue")
            decisionHandler(.allow)
        }
    }

    func handleActionClick(_ url: URL?) -> Bool {
        Sendsay.logger.log(.verbose, message: "[HTML] action for \(String(describing: url))")
        if isBlankNav(url) {
            // on first load
            // nothing to do, not need to continue loading
            return false
        }
        guard let htmlPayload else {
            Sendsay.logger.log(.error, message: "[HTML] Html content not loaded for action URL: \(String(describing: url))")
            onErrorCallback?(SendsayError.unknownError("Invalid state - HTML content not loaded"))
            return false
        }
        guard let url = url,
              let action = htmlPayload.findActionByUrl(url) else {
            Sendsay.logger.log(.error, message: "[HTML] Action URL \(url?.absoluteString ?? "<nil>") cannot be found as action")
            onErrorCallback?(SendsayError.unknownError("Invalid Action URL - not found"))
            // anyway we define it as Action, so URL opening has to be prevented
            return true
        }
        if htmlPayload.isCloseAction(url) {
            onCloseCallback?(action)
            return true
        }
        if htmlPayload.isActionUrl(url) {
            onActionCallback?(action)
            return true
        }
        // else
        Sendsay.logger.log(.warning, message: "[HTML] Unknown action URL: \(String(describing: url))")
        onErrorCallback?(SendsayError.unknownError("Invalid Action URL - unknown"))
        return false
    }
}

private extension WebActionManager {
    func isBlankNav(_ url: URL?) -> Bool {
        url?.absoluteString == "about:blank"
    }
}
