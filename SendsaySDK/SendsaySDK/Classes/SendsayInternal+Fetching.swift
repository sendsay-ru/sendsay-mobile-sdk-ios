//
//  SendsayInternal+Fetching.swift
//  SendsaySDK
//
//  Created by Dominik Hadl on 28/05/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation
import AdSupport
import AppTrackingTransparency

// MARK: - Fetching -

extension SendsayInternal {
    public func fetchRecommendation<T: RecommendationUserData>(
        with options: RecommendationOptions,
        completion: @escaping (Result<RecommendationResponse<T>>) -> Void
    ) {
        executeSafelyWithDependencies({
            $0.repository.fetchRecommendation(
                request: RecommendationRequest(options: options),
                for: $0.trackingManager.customerIds,
                completion: $1
            )
        }, completion: completion)
    }

    /// Fetch the list of your existing consent categories.
    ///
    /// - Parameter completion: A closure executed upon request completion containing the result
    ///                         which has either the returned data or error.
    public func fetchConsents(completion: @escaping (Result<ConsentsResponse>) -> Void) {
        executeSafelyWithDependencies({
            guard $0.configuration.authorization != Authorization.none else {
                if IntegrationManager.shared.isStopped {
                    completion(.failure(SendsayError.isStopped))
                }
                throw SendsayError.authorizationInsufficient
            }

            $0.repository.fetchConsents(completion: $1)
        }, completion: completion)
    }

    public func fetchAppInbox(completion: @escaping (Result<[MessageItem]>) -> Void) {
        executeSafelyWithDependencies({
            guard $0.configuration.authorization != Authorization.none else {
                if IntegrationManager.shared.isStopped {
                    completion(.failure(SendsayError.isStopped))
                }
                throw SendsayError.authorizationInsufficient
            }
            $0.appInboxManager?.fetchAppInbox(completion: $1)
        }, completion: completion)
    }

    public func fetchAppInboxItem(_ messageId: String, completion: @escaping (Result<MessageItem>) -> Void) {
        executeSafelyWithDependencies({
            guard $0.configuration.authorization != Authorization.none else {
                if IntegrationManager.shared.isStopped {
                    completion(.failure(SendsayError.isStopped))
                }
                throw SendsayError.authorizationInsufficient
            }
            $0.appInboxManager?.fetchAppInboxItem(messageId, completion: $1)
        }, completion: completion)
    }
    
    public func fetchIDFA(completion: @escaping (String?) -> Void) {
        if #available(iOS 14.5, *) {
            // Проверяем текущий статус, чтобы не вызывать окно повторно
            // Если разрешено или запрещено - сразу отдаем IDFA
            ATTrackingManager.requestTrackingAuthorization { status in
                        switch status {
                        case .authorized:
                            print("Разрешение к IDFA получено. Доступ открыт.")
                            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                            completion(idfa)
                        case .denied:
                            print("Разрешение к IDFA отклонено.")
                            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                            completion(idfa)
                        case .restricted:
                            print("Разрешение к IDFA ограничено родительским контролем или настройками устройства.")
                            completion(nil)
                        case .notDetermined:
                            print("Пользователь еще не принял решение по IDFA.")
                            // Внутри замыкания ATT всегда возвращается на фоновом потоке
                            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                            completion(idfa)
                        @unknown default:
                            break
                        }
                    }
        } else {
            // Для iOS меньше 14.4 окно ATT не существует, IDFA доступен напрямую
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            completion(idfa)
        }
    }
}
