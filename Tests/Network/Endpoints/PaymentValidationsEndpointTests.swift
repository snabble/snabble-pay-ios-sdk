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
        let endpoint = Endpoint<Any>.paymentValidations()
        XCTAssertEqual(endpoint.path, "/apps/payment-validations")
        XCTAssertEqual(endpoint.method, .post(nil))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testGetEndpoint() throws {
        let endpoint = Endpoint<Any>.paymentValidations(withID: "1", onEnvironment: .staging)
        XCTAssertEqual(endpoint.path, "/apps/payment-validations/1")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .staging)
    }

    func testEnvironment() throws {
        var endpoint = Endpoint<Any>.paymentValidations(onEnvironment: .staging)
        XCTAssertEqual(endpoint.environment, .staging)

        endpoint = Endpoint<Any>.paymentValidations(onEnvironment: .development)
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
        let instance = try JSONDecoder().decode(PaymentValidation.self, from: data)
        XCTAssertEqual(instance.id, "1")
        XCTAssertEqual(instance.state, PaymentValidation.State.successful)
        XCTAssertNotNil(instance.credential)

        XCTAssertEqual(instance.credential?.id, "1")
        XCTAssertEqual(instance.credential?.createdAt, "rfc3339")
        XCTAssertEqual(instance.credential?.iban, "DE123**********")
    }

}
