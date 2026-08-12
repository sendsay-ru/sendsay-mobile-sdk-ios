//
//  ServerRepository+VersionCheckRepository.swift
//  SendsaySDK
//
//  Created by Panaxeo on 25/04/2022.
//  Copyright © 2022 Sendsay. All rights reserved.
//


import Foundation

extension ServerRepository: VersionCheckRepository {

    var baseUrl: String { return "https://api.github.com/repos/sendsay-ru/%@/tags" }

    func requestLastSDKVersion(
        completion: @escaping (Result<String>) -> Void
    ) {
        var gitHubProject: String
        if isReactNativeSDK() {
            gitHubProject = "sendsay-mobile-sdk-react-native"
        } else if isFlutterSDK() {
            gitHubProject = "sendsay-mobile-sdk-flutter"
        } else if isXamarinSDK() {
            gitHubProject = "sendsay-mobile-sdk-xamarin"
        } else {
            gitHubProject = "sendsay-mobile-sdk-ios"
        }
        var request = URLRequest(url: URL(safeString: String(format: baseUrl, gitHubProject))!)

        // Create the basic request
        request.httpMethod = "GET"
        request.addValue(Constants.Repository.contentType,
                         forHTTPHeaderField: Constants.Repository.headerContentType)
        request.addValue(Constants.Repository.contentType,
                         forHTTPHeaderField: Constants.Repository.headerAccept)

        session
            .dataTask(with: request, completionHandler: handler(with: completion))
            .resume()
    }

    private func handler(
        with completion: @escaping ((Result<String>) -> Void)) -> ((Data?, URLResponse?, Error?) -> Void
        ) {
        return { (data, response, error) in
            // Check if we have any response at all
            guard let response = response else {
                completion(.failure(RepositoryError.connectionError))
                return
            }

            // Make sure we got the correct response type
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(RepositoryError.invalidResponse(response)))
                return
            }

            if let error = error {
                // handle server errors
                completion(.failure(error))
            } else if httpResponse.statusCode == 200, let data = data {
                do {
                    let jsonDecoder = JSONDecoder()
                    let list = try jsonDecoder.decode(Array<GitHubReleaseResponse>.self, from: data)
                    if let object = list.first {
                        completion(
                            .success(object.version)
                        )
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
