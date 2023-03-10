//
//  URLSession+Endpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import Combine
import SnabbleLogger

private extension URLResponse {
    func verify(with data: Data) throws {
        guard let httpResponse = self as? HTTPURLResponse else {
            Logger.shared.error("Unknown Response \(self)")
            throw HTTPError.unknownResponse(self)
        }
        guard httpResponse.httpStatusCode.responseType == .success else {
            let endpointError = try? JSONDecoder().decode(Endpoints.Error.self, from: data)
            Logger.shared.error("Invalid Response with statusCode \(httpResponse.statusCode) and errorObject \(String(describing: endpointError))")
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

extension URLSession {
    func publisher<Response: Decodable>(
        for endpoint: Endpoint<Response>
    ) -> AnyPublisher<Response, APIError> {
        let urlRequest: URLRequest
        do {
            urlRequest = try endpoint.urlRequest()
        } catch let error as APIError {
            Logger.shared.error("APIError \(error)")
            return Fail(error: error).eraseToAnyPublisher()
        } catch {
            Logger.shared.error("APIError unexpected \(error)")
            return Fail(error: APIError.unexpected(error)).eraseToAnyPublisher()
        }
        Logger.shared.debug("Start URLRequest: \(urlRequest)")
        return dataTaskPublisher(for: urlRequest)
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
                case let apiError as APIError:
                    return apiError
                default:
                    return .unexpected(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
