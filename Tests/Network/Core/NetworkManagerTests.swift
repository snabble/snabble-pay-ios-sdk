//
//  NetworkManagerTests.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import XCTest
import Combine
@testable import SnabblePayNetwork

final class NetworkManagerTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!
    var networkManager: NetworkManager!

    override func setUpWithError() throws {
        cancellables = Set<AnyCancellable>()
        networkManager = NetworkManager(session: .mockSession)
    }

    override func tearDownWithError() throws {
        cancellables = nil
        networkManager = nil
    }

    func testRequestWithError() throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data())
        }
        
        let endpoint: Endpoint<PaymentValidation> = .paymentValidations(onEnvironment: .development)

        let expectation = expectation(description: "CredentialsValidations")
        networkManager.publisher(for: endpoint, using: .init())
            .sink { completion in
                switch completion {
                case .failure:
                    expectation.fulfill()
                case .finished:
                    break
                }
            } receiveValue: { validation in
                XCTAssertNil(validation)
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 3.0)
    }

    func testRequest() throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = { request in
            if request.url?.path == "/apps/register" {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )!
                return (response, try! loadResource(filename: "register", withExtension: "json"))
            }

            if request.url?.path == "/apps/token" {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )!
                return (response, try! loadResource(filename: "token", withExtension: "json"))
            }

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, try! loadResource(filename: "payment-validation-no-credential", withExtension: "json"))
        }

        let endpoint: Endpoint<PaymentValidation> = .paymentValidations(onEnvironment: .development)

        let expectation = expectation(description: "payment-validations")
        var validation: PaymentValidation?
        networkManager.publisher(for: endpoint)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("error:", error.localizedDescription)
                case .finished:
                    expectation.fulfill()
                }
            } receiveValue: {
                validation = $0
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 10.0)

        XCTAssertNotNil(validation)
    }

}
