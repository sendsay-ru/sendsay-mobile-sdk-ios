//
//  Repository.swift
//  SendsaySDK
//
//  Created by Ricardo Tokashiki on 04/04/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation

protocol RepositoryType: AnyObject, TrackingRepository, FetchRepository, SelfCheckRepository, VersionCheckRepository {
    var configuration: Configuration { get set }

    /// Cancels all requests that are currently underway.
    func cancelRequests()
}

extension ServerRepository: RepositoryType {}
