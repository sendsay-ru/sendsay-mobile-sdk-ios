//
//  TrackingRepository.swift
//  SendsaySDK
//
//  Created by Panaxeo on 05/03/2020.
//  Copyright © 2020 Sendsay. All rights reserved.
//

import Foundation

public protocol TrackingRepository {
    func trackObject(
        _ object: TrackingObject,
        completion: @escaping ((EmptyResult<RepositoryError>) -> Void)
    )
}
