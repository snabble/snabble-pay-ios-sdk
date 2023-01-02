//
//  PaymentValidationsEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-20.
//

import XCTest
@testable import SnabblePayNetwork

final class PaymentValidationsEndpointTests: XCTestCase {

    func testPostEndpoint() throws {
        let endpoint = Endpoints.paymentValidations()
        XCTAssertEqual(endpoint.path, "/apps/payment-validations")
        XCTAssertEqual(endpoint.method, .post(nil))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testGetEndpoint() throws {
        let endpoint = Endpoints.paymentValidations(withID: "1", onEnvironment: .staging)
        XCTAssertEqual(endpoint.path, "/apps/payment-validations/1")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .staging)
    }

    func testEnvironment() throws {
        var endpoint = Endpoints.paymentValidations(onEnvironment: .staging)
        XCTAssertEqual(endpoint.environment, .staging)

        endpoint = Endpoints.paymentValidations(onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)
    }

    func testState() throws {
        XCTAssertEqual(PaymentValidation.State.pending.rawValue, "PENDING")
        XCTAssertEqual(PaymentValidation.State.successful.rawValue, "SUCCESSFUL")
        XCTAssertEqual(PaymentValidation.State.failed.rawValue, "FAILED")
        XCTAssertEqual(PaymentValidation.State.errored.rawValue, "ERRORED")
    }

    func testDecodingWithoutCredentials() throws {
        let data = try loadResource(filename: "payment-validation-no-credential", withExtension: "json")
        let instance = try JSONDecoder().decode(PaymentValidation.self, from: data)
        XCTAssertEqual(instance.id, "1")
        XCTAssertEqual(instance.state, PaymentValidation.State.pending)
        XCTAssertNil(instance.credential)
    }

    func testDecodingWithCredentials() throws {
        let data = try loadResource(filename: "payment-validation-credential", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(PaymentValidation.self, from: data)
        XCTAssertEqual(instance.id, "1")
        XCTAssertEqual(instance.state, PaymentValidation.State.successful)
        XCTAssertNotNil(instance.credential)

        XCTAssertEqual(instance.credential?.id, "1")
        XCTAssertEqual(instance.credential?.createdAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T09:24:38Z"))
        XCTAssertEqual(instance.credential?.iban, "DE123**********")
    }

}
