//
//  JSON+SnakeCase.swift
//  SendsaySDKShared
//
//  Created by Panaxeo on 12/03/2020.
//  Copyright © 2020 Sendsay. All rights reserved.
//

import Foundation

public extension JSONDecoder {
    static var snakeCase: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

public extension JSONEncoder {
    static var snakeCase: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}
