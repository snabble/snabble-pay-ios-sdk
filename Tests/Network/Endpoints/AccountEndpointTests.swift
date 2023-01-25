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
        let endpoint = Endpoints.Account.get()
        XCTAssertEqual(endpoint.path, "/apps/account")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testEnvironment() throws {
        var endpoint = Endpoints.Account.get(onEnvironment: .staging)
        XCTAssertEqual(endpoint.environment, .staging)

        endpoint = Endpoints.Account.get(onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)
    }

    func testDecodingEmpty() throws {
        let data = try loadResource(filename: "account-empty", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Account.self, from: data)
        XCTAssertTrue(instance.credentials.isEmpty)
        XCTAssertNotNil(instance.validationURL)
        XCTAssertEqual(instance.validationURL, "https://link.tink.com/1.0/account-check/?client_id=fcba35b7bf174d30bb7ce83c1870483a&redirect_uri=https%3A%2F%2Fpayments.snabble.io%2Fcallback&market=DE&locale=en_US&state=c6a1f37a-aefd-47e4-afbb-4baf0dcf7d30")
    }

    func testDecodingOne() throws {
        let data = try loadResource(filename: "account-one", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Account.self, from: data)
        XCTAssertFalse(instance.credentials.isEmpty)
        XCTAssertEqual(instance.credentials.count, 1)
        XCTAssertEqual(instance.credentials.first?.id, "1")
        XCTAssertEqual(instance.credentials.first?.name, "John Doe's Account")
        XCTAssertEqual(instance.credentials.first?.holderName, "John Doe")
        XCTAssertEqual(instance.credentials.first?.currencyCode.rawValue, "EUR")
        XCTAssertEqual(instance.credentials.first?.createdAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T09:24:38Z"))
        XCTAssertEqual(instance.credentials.first?.bank, "Bank Name")
        XCTAssertEqual(instance.credentials.first?.iban, "DE123**********")
        XCTAssertEqual(instance.credentials.first?.mandate.state, .accepted)
        XCTAssertNotNil(instance.validationURL)
        XCTAssertEqual(instance.validationURL, "https://link.tink.com/1.0/account-check/?client_id=fcba35b7bf174d30bb7ce83c1870483a&redirect_uri=https%3A%2F%2Fpayments.snabble.io%2Fcallback&market=DE&locale=en_US&state=c6a1f37a-aefd-47e4-afbb-4baf0dcf7d30")
    }

    func testDecodingMany() throws {
        let data = try loadResource(filename: "account-many", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Account.self, from: data)
        XCTAssertFalse(instance.credentials.isEmpty)
        XCTAssertEqual(instance.credentials.count, 2)
        XCTAssertEqual(instance.credentials.first?.id, "1")
        XCTAssertEqual(instance.credentials.first?.name, "John Doe's Account")
        XCTAssertEqual(instance.credentials.first?.holderName, "John Doe")
        XCTAssertEqual(instance.credentials.first?.currencyCode.rawValue, "EUR")
        XCTAssertEqual(instance.credentials.first?.createdAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T09:24:38Z"))
        XCTAssertEqual(instance.credentials.first?.bank, "Bank Name")
        XCTAssertEqual(instance.credentials.first?.iban, "DE123**********")
        XCTAssertEqual(instance.credentials.first?.mandate.state, .accepted)
        XCTAssertEqual(instance.credentials.last?.id, "2")
        XCTAssertEqual(instance.credentials.last?.name, "Jana Doe's Account")
        XCTAssertEqual(instance.credentials.last?.holderName, "Jana Doe")
        XCTAssertEqual(instance.credentials.last?.currencyCode.rawValue, "EUR")
        XCTAssertEqual(instance.credentials.last?.createdAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T10:24:38Z"))
        XCTAssertEqual(instance.credentials.last?.bank, "Bank Name")
        XCTAssertEqual(instance.credentials.last?.iban, "DE123**********")
        XCTAssertEqual(instance.credentials.last?.mandate.state, .declined)
        XCTAssertNotNil(instance.validationURL)
        XCTAssertEqual(instance.validationURL, "https://link.tink.com/1.0/account-check/?client_id=fcba35b7bf174d30bb7ce83c1870483a&redirect_uri=https%3A%2F%2Fpayments.snabble.io%2Fcallback&market=DE&locale=en_US&state=c6a1f37a-aefd-47e4-afbb-4baf0dcf7d30")
    }

    func testValidationCallbackURL() throws {
        let data = try loadResource(filename: "account-one", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Account.self, from: data)

        let url: URL = .init(string: "snabble-pay://account/validation")!
        XCTAssertTrue(instance.validateCallbackURL(url))

        var falseURL: URL = .init(string: "snabble://account/validation")!
        XCTAssertFalse(instance.validateCallbackURL(falseURL))

        falseURL = .init(string: "snabble-pay://AccOunT/ValidAtion")!
        XCTAssertFalse(instance.validateCallbackURL(falseURL))

        falseURL = .init(string: "snabble-pay://account/ValidAtion")!
        XCTAssertFalse(instance.validateCallbackURL(falseURL))

        falseURL = .init(string: "snabble-pay://account2/validation")!
        XCTAssertFalse(instance.validateCallbackURL(falseURL))
    }
}
