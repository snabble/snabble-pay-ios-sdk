//
//  PaymentValidationsEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-20.
//

import XCTest
@testable import SnabblePayNetwork

final class PaymentValidationsEndpointTests: XCTestCase {

    func testGetEndpoint() throws {
        let endpoint = Endpoints.paymentValidations()
        XCTAssertEqual(endpoint.path, "/apps/payment-validations")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .production)
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
        XCTAssertEqual(PaymentValidation.State.error.rawValue, "ERROR")
    }

    func testDecodingFailed() throws {
        let data = try loadResource(filename: "payment-validation-failed", withExtension: "json")
        let instance = try JSONDecoder().decode(PaymentValidation.self, from: data)
        XCTAssertEqual(instance.state, PaymentValidation.State.failed)
        XCTAssertNil(instance.credentials)
        XCTAssertNil(instance.validationLink)
        XCTAssertNotNil(instance.message)
        XCTAssertEqual(instance.message, "some error message")
    }

    func testDecodingError() throws {
        let data = try loadResource(filename: "payment-validation-error", withExtension: "json")
        let instance = try JSONDecoder().decode(PaymentValidation.self, from: data)
        XCTAssertEqual(instance.state, PaymentValidation.State.error)
        XCTAssertNil(instance.credentials)
        XCTAssertNil(instance.validationLink)
        XCTAssertNotNil(instance.message)
        XCTAssertEqual(instance.message, "some error message")
    }

    func testDecodingPending() throws {
        let data = try loadResource(filename: "payment-validation-pending", withExtension: "json")
        let instance = try JSONDecoder().decode(PaymentValidation.self, from: data)
        XCTAssertEqual(instance.state, PaymentValidation.State.pending)
        XCTAssertNil(instance.credentials)
        XCTAssertNotNil(instance.validationLink)
        XCTAssertEqual(instance.validationLink?.absoluteString, "https://link.tink.com/1.0/account-check/?client_id=fcba35b7bf174d30bb7ce83c1870483a&redirect_uri=https%3A%2F%2Fpayments.snabble.io%2Fcallback&market=DE&locale=en_US&state=c6a1f37a-aefd-47e4-afbb-4baf0dcf7d30")
        XCTAssertNil(instance.credentials)
    }

    func testDecodingSuccessful() throws {
        let data = try loadResource(filename: "payment-validation-successful", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(PaymentValidation.self, from: data)
        XCTAssertEqual(instance.state, PaymentValidation.State.successful)
        XCTAssertNotNil(instance.credentials)

        XCTAssertEqual(instance.credentials?.id, "1")
        XCTAssertEqual(instance.credentials?.name, "John Doe's Account")
        XCTAssertEqual(instance.credentials?.holderName, "John Doe")
        XCTAssertEqual(instance.credentials?.currencyCode.rawValue, "EUR")
        XCTAssertEqual(instance.credentials?.createdAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T09:24:38Z"))
        XCTAssertEqual(instance.credentials?.bank, "Bank Name")
        XCTAssertEqual(instance.credentials?.iban, "DE123**********")
    }

}
