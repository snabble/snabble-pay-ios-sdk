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
        let endpoint = Endpoints.account()
        XCTAssertEqual(endpoint.path, "/apps/account")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testEnvironment() throws {
        var endpoint = Endpoints.account(onEnvironment: .staging)
        XCTAssertEqual(endpoint.environment, .staging)

        endpoint = Endpoints.account(onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)
    }

    func testState() throws {
        XCTAssertEqual(Account.State.pending.rawValue, "PENDING")
        XCTAssertEqual(Account.State.successful.rawValue, "SUCCESSFUL")
        XCTAssertEqual(Account.State.failed.rawValue, "FAILED")
        XCTAssertEqual(Account.State.error.rawValue, "ERROR")
    }

    func testDecodingFailed() throws {
        let data = try loadResource(filename: "account-failed", withExtension: "json")
        let instance = try JSONDecoder().decode(Account.self, from: data)
        XCTAssertEqual(instance.state, Account.State.failed)
        XCTAssertNil(instance.credentials)
        XCTAssertNil(instance.validationLink)
        XCTAssertNotNil(instance.message)
        XCTAssertEqual(instance.message, "some error message")
    }

    func testDecodingError() throws {
        let data = try loadResource(filename: "account-error", withExtension: "json")
        let instance = try JSONDecoder().decode(Account.self, from: data)
        XCTAssertEqual(instance.state, Account.State.error)
        XCTAssertNil(instance.credentials)
        XCTAssertNil(instance.validationLink)
        XCTAssertNotNil(instance.message)
        XCTAssertEqual(instance.message, "some error message")
    }

    func testDecodingPending() throws {
        let data = try loadResource(filename: "account-pending", withExtension: "json")
        let instance = try JSONDecoder().decode(Account.self, from: data)
        XCTAssertEqual(instance.state, Account.State.pending)
        XCTAssertNil(instance.credentials)
        XCTAssertNotNil(instance.validationLink)
        XCTAssertEqual(instance.validationLink?.absoluteString, "https://link.tink.com/1.0/account-check/?client_id=fcba35b7bf174d30bb7ce83c1870483a&redirect_uri=https%3A%2F%2Fpayments.snabble.io%2Fcallback&market=DE&locale=en_US&state=c6a1f37a-aefd-47e4-afbb-4baf0dcf7d30")
        XCTAssertNil(instance.credentials)
    }

    func testDecodingSuccessful() throws {
        let data = try loadResource(filename: "account-successful", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Account.self, from: data)
        XCTAssertEqual(instance.state, Account.State.successful)
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
