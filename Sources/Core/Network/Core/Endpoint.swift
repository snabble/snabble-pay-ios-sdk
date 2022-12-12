//
//  Endpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation

protocol Endpoint<Result> {
    associatedtype Result

    var path: String { get }

    var environment: Environmentable { get }

    var method: HTTPMethod { get }
    var headerFields: [String: String]? { get }

    var cachePolicy: URLRequest.CachePolicy { get }
}

extension Endpoint {
    var cachePolicy: URLRequest.CachePolicy {
        .useProtocolCachePolicy
    }

    var environment: Environmentable {
        Environment.development
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

        request.allHTTPHeaderFields = environment.headers ?? [:]
        request.allHTTPHeaderFields?.merge(headerFields ?? [:], uniquingKeysWith: { _, new in new })
        request.httpMethod = method.value
        request.cachePolicy = cachePolicy

        return request
    }
}
