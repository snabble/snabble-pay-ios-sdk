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
    func tryVerifyResponse() -> AnyPublisher<Output, Swift.Error> {
        tryMap { (data, response) throws -> Output in
            try response.verify(with: data)
            return (data, response)
        }
        .eraseToAnyPublisher()
    }
}

@available(iOS 13, *)
extension URLSession {
    func publisher<Response: Decodable>(
        for endpoint: Endpoint<Response>
    ) -> AnyPublisher<Response, NetworkError> {
        dataTaskPublisher(for: endpoint.urlRequest)
            .tryVerifyResponse()
            .map(\.data)
            .decode(type: Response.self, decoder: endpoint.jsonDecoder)
            .mapError { error -> NetworkError in
                switch error {
                case let httpError as HTTPError:
                    return .httpError(httpError)
                case let decodingError as DecodingError:
                    return .decodingError(decodingError)
                default:
                    return .unexpected
                }
            }
            .eraseToAnyPublisher()
    }
}
