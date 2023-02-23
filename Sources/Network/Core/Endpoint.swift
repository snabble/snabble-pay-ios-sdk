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
    public var urlRequest: URLRequest {
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
            request.httpBody = nil
        }

        let headerFields = environment.headerFields.merging(headerFields, uniquingKeysWith: { _, new in new })
        request.allHTTPHeaderFields = headerFields

        if let token = token {
            request.setValue("\(token.type.rawValue) \(token.accessToken.rawValue)", forHTTPHeaderField: "Authorization")
        }

        request.httpMethod = method.value
        request.cachePolicy = .useProtocolCachePolicy

        return request
    }
}

extension Endpoints {
    public struct Error: Decodable, Equatable {
        public let reason: Reason
        public let message: String?

        enum CodingKeys: String, CodingKey {
            case reason
            case message
        }

        enum RootKeys: String, CodingKey {
            case error
        }

        public enum Reason: String, Decodable {
            case mandateNotAccepted = "mandate_not_accepted"
            case accountNotFound = "account_not_found"
            case validationError = "validation_error"
            case unknown
        }

        public init(from decoder: Decoder) throws {
            let topLevelContainer = try decoder.container(keyedBy: RootKeys.self)
            let container = try topLevelContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .error)
            self.reason = try container.decode(Endpoints.Error.Reason.self, forKey: Endpoints.Error.CodingKeys.reason)
            self.message = try container.decodeIfPresent(String.self, forKey: Endpoints.Error.CodingKeys.message)
        }
    }
}

extension Endpoints.Error.Reason {
    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
