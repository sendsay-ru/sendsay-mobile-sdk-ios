//
//  InitConfigManager.swift
//  SendsaySDK
//
//  Created by Stas ProSky on 21.07.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import UIKit

final class InitConfigManager: InitConfigManagerType, @unchecked Sendable {

    private let repository: RepositoryType
    private let cache: InitConfigCache

    internal var inRefetchCallback: Void?
    internal var sessionStartDate: Date = Date()
    private static let refetchConfigAfter: TimeInterval = 60 // fetch new config if sessionStart is older than sessionStart + this
    private lazy var identifyFlowQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "identify flow"
        return queue
    }()

    init(
        repository: RepositoryType,
        cache: InitConfigCache = InitConfigCache()
    ) {
        self.repository = repository
        self.cache = cache

        IntegrationManager.shared.onIntegrationStoppedCallbacks.append { [weak self] in
            guard let self else { return }
//            self.cache.clear()
        }
    }

    // MARK: - Methods
    private func shouldRefetch(timestamp: TimeInterval) -> Bool {
        let refreshTime = cache.getInitConfigTimestamp() + InitConfigManager.refetchConfigAfter
        return refreshTime < timestamp
    }

//    private func handleInitConfig(
//        _ config: ConfigItem,
//        callback: ((InitConfigView?) -> Void)?
//    ) {
//        if !message.hasPayload() && message.variantId == -1 {
//            Sendsay.logger.log(
//                .verbose,
//                message: "[InApp] Only logging in-app message for control group '\(message.name)'"
//            )
//            self.trackInitConfigShown(message)
//            callback?(nil)
//        } else {
//            Task { [weak self] in
//                await self?.showInitConfig(message, callback: callback)
//            }
//        }
//    }

//    private func trackInitConfigError(
//        _ message: InitConfig,
//        _ error: String
//    ) {
//        self.trackingConsentManager.trackInitConfigError(message: message, error: error, mode: .CONSIDER_CONSENT)
//        Sendsay.shared.InitConfigsDelegate.InitConfigError(message: message, errorMessage: error)
//    }

//    private func trackInitConfigShown(
//        _ message: InitConfig
//    ) {
//        displayStatusStore.didDisplay(message, at: Date())
//        trackingConsentManager.trackInitConfigShown(message: message, mode: .CONSIDER_CONSENT)
//        Sendsay.shared.InitConfigsDelegate.InitConfigShown(message: message)
//        Sendsay.shared.telemetryManager?.report(
//            eventWithType: .showInitConfig,
//            properties: ["messageType": message.rawMessageType ?? "null"]
//        )
//    }

    func fetchInitConfig(for event: [DataType], completion: ConfigItem? = nil) {
        guard !IntegrationManager.shared.isStopped else {
            Sendsay.logger.log(
                .error,
                message: "InitConfig fetch failed, SDK is stopping"
            )
            return
        }
        repository.fetchInitConfig { [weak self] result in
            guard !IntegrationManager.shared.isStopped else {
                Sendsay.logger.log(
                    .error,
                    message: "InitConfig fetch failed, SDK is stopping"
                )
                return
            }
            guard case let .success(response) = result,
                    let self
            else {
                Sendsay.logger.log(
                    .verbose,
                    message: "[InitConfig] fetchInitConfig failed '\(result)'"
                )
                return
            }
            Sendsay.logger.log(
                .verbose,
                message: "[InitConfig] Fetch completed \(response.results.description)"
            )
            self.cache.saveConfig(config: response.results)
        }
    }

    @discardableResult
    internal func isFetchInitConfigDone(for event: [DataType]) async throws -> Bool {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                self.repository.fetchInitConfig { result in
                    Task {
                        switch result {
                        case let .success(response):
//                            if var currentCustomerIds = Sendsay.shared.trackingManager?.customerIds, !currentCustomerIds.isEmpty {
                                var config = response.results
//                                if !event.customerIds.compareWith(other: currentCustomerIds) {
//                                    Sendsay.logger.log(
//                                        .verbose,
//                                        message: "[InitConfig] Fetch InitConfigs - different customer ids"
//                                    )
//                                    continuation.resume(returning: true)
//                                } else {
                                    Sendsay.logger.log(
                                        .verbose,
                                        message: "[InitConfig] Fetch completed \(config.description)"
                                    )
                                    self.cache.saveConfig(config: config)
                                    continuation.resume(returning: true)
//                                }
//                            } else {
//                                Sendsay.logger.log(
//                                    .verbose,
//                                    message: "[InApp] fetchInitConfig failed '\(result)', current customer: '\(Sendsay.shared.trackingManager?.customerIds ?? [:])'"
//                                )
//                                continuation.resume(throwing: InitConfigError.fetchInitConfigFailed)
//                            }
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
            }
        }
    }
}
