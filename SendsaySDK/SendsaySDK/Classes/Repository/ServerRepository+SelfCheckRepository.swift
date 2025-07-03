//
//  ServerRepository+SelfCheckRepository.swift
//  SendsaySDK
//
//  Created by Panaxeo on 26/05/2020.
//  Copyright © 2020 Sendsay. All rights reserved.
//

import Foundation

extension ServerRepository: SelfCheckRepository {
    func requestSelfCheckPush(
        for customerIds: [String: String],
        pushToken: String,
        completion: @escaping (EmptyResult<RepositoryError>) -> Void
    ) {
        let router = RequestFactory(sendsayProject: configuration.mainProject, route: .pushSelfCheck)
        let request = router.prepareRequest(
            parameters: PushSelfCheckRequest(pushToken: pushToken),
            customerIds: customerIds
        )
        session
            .dataTask(with: request, completionHandler: router.handler(with: completion))
            .resume()
    }
}
