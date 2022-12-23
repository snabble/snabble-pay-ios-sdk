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
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://payment.snabble.io/apps/payment-validations")!,
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

}
