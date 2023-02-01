//
//  MandateEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-23.
//

import XCTest
@testable import SnabblePayCore
import SnabblePayNetwork
import TestHelper

final class MandateEndpointTests: XCTestCase {

    func testGetEndpoint() throws {
        let endpoint = Endpoints.Accounts.Mandate.get(accountId: "1")
        XCTAssertEqual(endpoint.path, "/apps/accounts/1/mandate")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testAcceptEndpoint() throws {
        let jsonObject = ["state": "ACCEPTED"]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)

        let endpoint = Endpoints.Accounts.Mandate.accept(accountId: "3")
        XCTAssertEqual(endpoint.path, "/apps/accounts/3/mandate")
        XCTAssertEqual(endpoint.method, .patch(jsonData))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testDeclineEndpoint() throws {
        let jsonObject = ["state": "DECLINED"]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)

        let endpoint = Endpoints.Accounts.Mandate.decline(accountId: "2")
        XCTAssertEqual(endpoint.path, "/apps/accounts/2/mandate")
        XCTAssertEqual(endpoint.method, .patch(jsonData))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testEnvironment() throws {
        var endpoint = Endpoints.Accounts.Mandate.get(accountId: "1", onEnvironment: .staging)
        XCTAssertEqual(endpoint.environment, .staging)

        endpoint = Endpoints.Accounts.Mandate.accept(accountId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Accounts.Mandate.decline(accountId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Accounts.Mandate.get(accountId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Accounts.Mandate.accept(accountId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Accounts.Mandate.decline(accountId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)
    }

    func testState() throws {
        XCTAssertEqual(Account.Mandate.State.pending.rawValue, "PENDING")
        XCTAssertEqual(Account.Mandate.State.accepted.rawValue, "ACCEPTED")
        XCTAssertEqual(Account.Mandate.State.declined.rawValue, "DECLINED")
    }

    func testEquatable() throws {
        let mandate1 = Account.Mandate(state: .accepted, text: "foobar")
        let mandate2 = Account.Mandate(state: .accepted, text: nil)
        let mandate3 = Account.Mandate(state: .declined, text: "foobar")

        XCTAssertEqual(mandate1, mandate2)
        XCTAssertFalse(mandate3 == mandate2)
    }

    func testDecoder() throws {
        let data = try loadResource(inBundle: .module, filename: "mandate", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Account.Mandate.self, from: data)
        XCTAssertEqual(instance.state, .accepted)
        XCTAssertEqual(instance.text, "mandate text")
    }
}