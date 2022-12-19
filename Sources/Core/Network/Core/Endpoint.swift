//
//  Endpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation

struct Endpoint<Response> {
    let method: HTTPMethod
    let path: String

    let environment: Environment

    var token: Token?

    var headerFields: [String: String] = [:]
    var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy

    init(path: String, method: HTTPMethod, environment: Environment = .production) {
        self.path = path
        self.method = method
        self.environment = environment
    }
}

extension Endpoint {
    var urlRequest: URLRequest {
        var components = URLComponents(
            url: environment.baseURL,
            resolvingAgainstBaseURL: false
        )
        components?.path = path

        switch method {
        case .get(let queryItems):
            components?.queryItems = queryItems?.sorted(by: \.name)
        default:
            break
        }

        guard let url = components?.url else {
            preconditionFailure("Couldn't create a url from components...")
        }

        var request = URLRequest(url: url)

        switch method {
        case .post(let data), .put(let data), .patch(let data):
            request.httpBody = data
        default:
            break
        }

        let headerFields = environment.headerFields.merging(headerFields, uniquingKeysWith: { _, new in new })
        request.allHTTPHeaderFields = headerFields

        if let token = token {
            request.setValue("\(token.type.rawValue) \(token.accessToken.rawValue)", forHTTPHeaderField: "Authentication")
        }

        request.httpMethod = method.value
        request.cachePolicy = cachePolicy

        return request
    }
}
