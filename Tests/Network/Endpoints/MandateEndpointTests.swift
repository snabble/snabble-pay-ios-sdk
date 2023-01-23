//
//  MandateEndpointTests.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-23.
//

import XCTest
@testable import SnabblePayNetwork

final class MandateEndpointTests: XCTestCase {

    func testGetEndpoint() throws {
        let endpoint = Endpoints.Account.Mandate.get()
        XCTAssertEqual(endpoint.path, "/apps/account/mandate")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testAcceptEndpoint() throws {
        let jsonObject = ["state": "ACCEPTED"]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)

        let endpoint = Endpoints.Account.Mandate.accept()
        XCTAssertEqual(endpoint.path, "/apps/account/mandate")
        XCTAssertEqual(endpoint.method, .patch(jsonData))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testDeclineEndpoint() throws {
        let jsonObject = ["state": "DECLINED"]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)

        let endpoint = Endpoints.Account.Mandate.decline()
        XCTAssertEqual(endpoint.path, "/apps/account/mandate")
        XCTAssertEqual(endpoint.method, .patch(jsonData))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testEnvironment() throws {
        var endpoint = Endpoints.Account.Mandate.get(onEnvironment: .staging)
        XCTAssertEqual(endpoint.environment, .staging)

        endpoint = Endpoints.Account.Mandate.accept(onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Account.Mandate.decline(onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Account.Mandate.get(onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Account.Mandate.accept(onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Account.Mandate.decline(onEnvironment: .development)
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
}
