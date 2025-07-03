//
//  Configuration+Anonymize.swift
//  SendsaySDKShared
//
//  Created by Panaxeo on 12/01/2021.
//  Copyright © 2021 Sendsay. All rights reserved.
//

import Foundation

public extension Configuration {
    mutating func switchProjects(
        mainProject: SendsayProject,
        projectMapping: [EventType: [SendsayProject]]?
    ) {
        baseUrl = mainProject.baseUrl
        projectToken = mainProject.projectToken
        authorization = mainProject.authorization
        self.projectMapping = projectMapping
    }
}
