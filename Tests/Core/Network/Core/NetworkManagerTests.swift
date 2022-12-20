//
//  NetworkManagerTests.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import XCTest
import Combine
@testable import SnabblePayCore

final class NetworkManagerTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!
    var networkManager: NetworkManager!

    override func setUpWithError() throws {
        cancellables = Set<AnyCancellable>()
        networkManager = NetworkManager()
    }

    override func tearDownWithError() throws {
        cancellables = nil
        networkManager = nil
    }

    func testExample() throws {
        let endpoint: Endpoint<PaymentValidation> = .paymentValidations(onEnvironment: .development)

        let expectation = expectation(description: "CredentialsValidations")
        networkManager.publisher(for: endpoint, using: .init())
            .sink { completion in
                print(completion)
                expectation.fulfill()
            } receiveValue: { validation in
                print(validation)
            }.store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }

}
