//
//  Endpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation

/// A namespace for types that serve as `Endpoint`.
///
/// The various endpoints defined as extensions on ``Endpoint``.
public enum Endpoints {}

public struct Endpoint<Response> {
    public let method: HTTPMethod
    public let path: String
    public let environment: Environment

    var jsonDecoder: JSONDecoder = {
        let jsonDecoder: JSONDecoder = .init()
        jsonDecoder.dateDecodingStrategy = .iso8601
        return jsonDecoder
    }()

    var token: Token?

    var headerFields: [String: String] = [:]

    public init(path: String, method: HTTPMethod, environment: Environment = .production) {
        self.path = path
        self.method = method
        self.environment = environment
    }
}

extension Endpoint {
    public func urlRequest() throws -> URLRequest {
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
            throw APIError.invalidRequestError("baseURL: \(environment.baseURL), path: \(path)")
        }

        var request = URLRequest(url: url)

        switch method {
        case .post(let data), .put(let data), .patch(let data):
            request.httpBody = data
        default:
            request.httpBody = nil
        }

        let headerFields = environment.headerFields.merging(headerFields, uniquingKeysWith: { _, new in new })
        request.allHTTPHeaderFields = headerFields

        if let token = token {
            request.setValue("\(token.type.rawValue) \(token.value)", forHTTPHeaderField: "Authorization")
        }

        request.httpMethod = method.value
        request.cachePolicy = .useProtocolCachePolicy

        return request
    }
}
