//
//  PaymentValidationsEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-20.
//

import XCTest
@testable import SnabblePayNetwork

final class PaymentValidationsEndpointTests: XCTestCase {

    func testCheckEndpoint() throws {
        let endpoint = Endpoints.Accounts.check(appUri: "snabble-pay://account/check")
        XCTAssertEqual(endpoint.path, "/apps/accounts/check")
        XCTAssertEqual(endpoint.method, .get([.init(name: "appUri", value: "snabble-pay://account/check")]))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testGetEndpoint() throws {
        let endpoint = Endpoints.Accounts.get()
        XCTAssertEqual(endpoint.path, "/apps/accounts")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testGetIdEndpoint() throws {
        let endpoint = Endpoints.Accounts.get(id: "1")
        XCTAssertEqual(endpoint.path, "/apps/accounts/1")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testDeleteIdEndpoint() throws {
        let endpoint = Endpoints.Accounts.delete(id: "1")
        XCTAssertEqual(endpoint.path, "/apps/accounts/1")
        XCTAssertEqual(endpoint.method, .delete)
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testEnvironment() throws {
        var endpoint1 = Endpoints.Accounts.get(id: "1", onEnvironment: .staging)
        XCTAssertEqual(endpoint1.environment, .staging)

        var endpoint2 = Endpoints.Accounts.get(onEnvironment: .development)
        XCTAssertEqual(endpoint2.environment, .development)

        var endpoint3 = Endpoints.Accounts.delete(id: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint3.environment, .development)

        var endpoint4 = Endpoints.Accounts.check(appUri: "snabble-pay://account/check", onEnvironment: .staging)
        XCTAssertEqual(endpoint4.environment, .staging)

        endpoint1 = Endpoints.Accounts.get(id: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint1.environment, .development)

        endpoint2 = Endpoints.Accounts.get(onEnvironment: .development)
        XCTAssertEqual(endpoint2.environment, .development)

        endpoint3 = Endpoints.Accounts.delete(id: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint3.environment, .development)

        endpoint4 = Endpoints.Accounts.check(appUri: "snabble-pay://account/check", onEnvironment: .development)
        XCTAssertEqual(endpoint4.environment, .development)
    }

    func testAccountCheckDecoding() throws {
        let data = try loadResource(filename: "account-check", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Account.Check.self, from: data)
        XCTAssertEqual(instance.validationURL, "https://link.tink.com/1.0/account-check/?client_id=fcba35b7bf174d30bb7ce83c1870483a&redirect_uri=https%3A%2F%2Fpayments.snabble.io%2Fcallback&market=DE&locale=en_US&state=c6a1f37a-aefd-47e4-afbb-4baf0dcf7d30")
        XCTAssertEqual(instance.appUri, "snabble-pay://account/check")
    }

    func testDecodingEmpty() throws {
        let data = try loadResource(filename: "account-empty", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode([Account].self, from: data)
        XCTAssertTrue(instance.isEmpty)
    }

    func testDecodingOne() throws {
        let data = try loadResource(filename: "account-one", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode([Account].self, from: data)
        XCTAssertFalse(instance.isEmpty)
        XCTAssertEqual(instance.count, 1)
        XCTAssertEqual(instance.first?.id, "1")
        XCTAssertEqual(instance.first?.name, "John Doe's Account")
        XCTAssertEqual(instance.first?.holderName, "John Doe")
        XCTAssertEqual(instance.first?.currencyCode.rawValue, "EUR")
        XCTAssertEqual(instance.first?.createdAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T09:24:38Z"))
        XCTAssertEqual(instance.first?.bank, "Bank Name")
        XCTAssertEqual(instance.first?.iban, "DE123**********")
        XCTAssertEqual(instance.first?.mandate.state, .accepted)
    }

    func testDecodingMany() throws {
        let data = try loadResource(filename: "account-many", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode([Account].self, from: data)
        XCTAssertFalse(instance.isEmpty)
        XCTAssertEqual(instance.count, 2)
        XCTAssertEqual(instance.first?.id, "1")
        XCTAssertEqual(instance.first?.name, "John Doe's Account")
        XCTAssertEqual(instance.first?.holderName, "John Doe")
        XCTAssertEqual(instance.first?.currencyCode.rawValue, "EUR")
        XCTAssertEqual(instance.first?.createdAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T09:24:38Z"))
        XCTAssertEqual(instance.first?.bank, "Bank Name")
        XCTAssertEqual(instance.first?.iban, "DE123**********")
        XCTAssertEqual(instance.first?.mandate.state, .accepted)
        XCTAssertEqual(instance.last?.id, "2")
        XCTAssertEqual(instance.last?.name, "Jana Doe's Account")
        XCTAssertEqual(instance.last?.holderName, "Jana Doe")
        XCTAssertEqual(instance.last?.currencyCode.rawValue, "EUR")
        XCTAssertEqual(instance.last?.createdAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T10:24:38Z"))
        XCTAssertEqual(instance.last?.bank, "Bank Name")
        XCTAssertEqual(instance.last?.iban, "DE123**********")
        XCTAssertEqual(instance.last?.mandate.state, .declined)
    }
}
