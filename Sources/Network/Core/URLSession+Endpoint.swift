//
//  URLSession+Endpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import Combine

private extension URLResponse {
    func verify(with data: Data) throws {
        guard let httpResponse = self as? HTTPURLResponse else {
            throw HTTPError.unknownResponse(self)
        }
        guard httpResponse.httpStatusCode.responseType == .success else {
            let endpointError = try? JSONDecoder().decode(Endpoints.Error.self, from: data)
            throw HTTPError.invalidResponse(httpResponse.httpStatusCode, endpointError)
        }
    }
}

private extension Publisher where Output == (data: Data, response: URLResponse), Failure == URLError {
    func tryVerifyResponse() -> AnyPublisher<Output, HTTPError> {
        tryMap { (data, response) throws -> Output in
            try response.verify(with: data)
            return (data, response)
        }
        .mapError { $0 as? HTTPError ?? .unexpected($0) }
        .eraseToAnyPublisher()
    }
}

extension URLSession {
    func publisher<Response: Decodable>(
        for endpoint: Endpoint<Response>
    ) -> AnyPublisher<Response, APIError> {
        dataTaskPublisher(for: endpoint.urlRequest)
            .tryVerifyResponse()
            .map(\.data)
            .decode(type: Response.self, decoder: endpoint.jsonDecoder)
            .mapError { error -> APIError in
                switch error {
                case let urlError as URLError:
                    return .transportError(urlError)
                case let httpError as HTTPError:
                    switch httpError {
                    case .unknownResponse(let urlResponse):
                        return APIError.invalidResponse(urlResponse)
                    case .invalidResponse(let statusCode, let endpointError):
                        return APIError.validationError(httpStatusCode: statusCode, error: endpointError)
                    case .unexpected:
                        return APIError.unexpected(error)
                    }
                case let decodingError as DecodingError:
                    return .decodingError(decodingError)
                default:
                    return .unexpected(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
