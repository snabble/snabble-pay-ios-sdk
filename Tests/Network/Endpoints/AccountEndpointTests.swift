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

    func testDecodingFailed() throws {
        let data = try loadResource(filename: "account-failed", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Account.self, from: data)
        XCTAssertEqual(instance.state, Account.State.failed("foobar"))
        switch instance.state {
        case .failed(let message):
            XCTAssertEqual(message, "some error message")
        default:
            XCTFail("State should be failed")
        }
    }

    func testDecodingError() throws {
        let data = try loadResource(filename: "account-error", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Account.self, from: data)
        XCTAssertEqual(instance.state, Account.State.error("foobar"))
        switch instance.state {
        case .error(let message):
            XCTAssertEqual(message, "some error message")
        default:
            XCTFail("State should be error")
        }
    }

    func testDecodingPending() throws {
        let data = try loadResource(filename: "account-pending", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Account.self, from: data)
        XCTAssertEqual(instance.state, Account.State.pending(URL(string: "https://www.google.de")!))

        switch instance.state {
        case .pending(let url):
            XCTAssertEqual(url.absoluteString, "https://link.tink.com/1.0/account-check/?client_id=fcba35b7bf174d30bb7ce83c1870483a&redirect_uri=https%3A%2F%2Fpayments.snabble.io%2Fcallback&market=DE&locale=en_US&state=c6a1f37a-aefd-47e4-afbb-4baf0dcf7d30")
        default:
            XCTFail("State should be pending")
        }
    }

    func testDecodingSuccessful() throws {
        let data = try loadResource(filename: "account-successful", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Account.self, from: data)

        let credentials = Account.Credentials(id: "1", name: "Foobar", holderName: "Max Mustermann", currencyCode: "EUR", bank: "N26 Bank", createdAt: Date(), iban: "DE123****321")
        let mandate = Account.Mandate(state: .accepted, text: nil)
        XCTAssertEqual(instance.state, Account.State.successful(credentials, mandate))
        switch instance.state {
        case .successful(let credentials, let mandate):
            XCTAssertEqual(credentials.id, "1")
            XCTAssertEqual(credentials.name, "John Doe's Account")
            XCTAssertEqual(credentials.holderName, "John Doe")
            XCTAssertEqual(credentials.currencyCode.rawValue, "EUR")
            XCTAssertEqual(credentials.createdAt, TestingDefaults.dateFormatter.date(from: "2022-12-22T09:24:38Z"))
            XCTAssertEqual(credentials.bank, "Bank Name")
            XCTAssertEqual(credentials.iban, "DE123**********")
            XCTAssertEqual(mandate?.state, .accepted)
        default:
            XCTFail("State should be pending")
        }
    }

    func testValidationCallbackURL() throws {
        let data = try loadResource(filename: "account-successful", withExtension: "json")
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
