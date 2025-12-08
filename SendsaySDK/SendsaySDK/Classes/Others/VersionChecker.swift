//
//  VersionChecker.swift
//  SendsaySDK
//
//  Created by Panaxeo on 25/04/2022.
//  Copyright © 2022 Sendsay. All rights reserved.
//


import Foundation

public protocol SendsayVersionProvider {
    init()
    func getVersion() -> String
}

internal class VersionChecker {
    internal let repository: ServerRepository
    internal init(repository: ServerRepository) {
        self.repository = repository
    }

    func warnIfNotLatestSDKVersion() {
        var actualVersion: String?
        var gitProject: String
//        if isReactNativeSDK() {
//            actualVersion = getReactNativeSDKVersion()
//            gitProject = "sendsay-react-native-sdk"
//        } else
        if isFlutterSDK() {
            actualVersion = getFlutterSDKVersion()
            gitProject = "sendsay-mobile-sdk-flutter"
        } else if isXamarinSDK() {
            actualVersion = getXamarinSDKVersion()
            gitProject = "sendsay-xamarin-sdk"
        } else {
            actualVersion = Sendsay.version
            gitProject = "sendsay-mobile-sdk-ios"
        }

        if let actualVersion = actualVersion {
            repository.requestLastSDKVersion(completion: { result in
                if let error = result.error {
                    Sendsay.logger.log(
                        LogLevel.error,
                        message: "Failed to retrieve last Sendsay SDK version: \(error)."
                    )
                } else if let lastVersion = result.value {
                    if actualVersion.versionCompare(lastVersion) < 0 {
                        Sendsay.logger.log(
                            LogLevel.error,
                            message: "\n####\n" +
                            "#### A newer version of the Sendsay SDK is available!\n" +
                            "#### Your version: \(actualVersion)  Last version: \(lastVersion)\n" +
                            "#### Upgrade to the latest version to benefit from the new features " +
                                    "and better stability:\n" +
                            "#### https://github.com/sendsay-ru/\(gitProject)/releases\n" +
                            "####"
                        )
                    }
                }
            })
        } else {
            Sendsay.logger.log(
                LogLevel.error,
                message: "Failed to retrieve last Sendsay SDK version."
            )
        }
    }
}

extension String {
    func versionCompare(_ otherVersion: String) -> Int {
        return self.compare(otherVersion, options: .numeric).rawValue
    }
}
