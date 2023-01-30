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
        let endpoint = Endpoints.Account.Credentials.Mandate.get(credentialsId: "1")
        XCTAssertEqual(endpoint.path, "/apps/account/credentials/1/mandate")
        XCTAssertEqual(endpoint.method, .get(nil))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testAcceptEndpoint() throws {
        let jsonObject = ["state": "ACCEPTED"]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)

        let endpoint = Endpoints.Account.Credentials.Mandate.accept(credentialsId: "3")
        XCTAssertEqual(endpoint.path, "/apps/account/credentials/3/mandate")
        XCTAssertEqual(endpoint.method, .patch(jsonData))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testDeclineEndpoint() throws {
        let jsonObject = ["state": "DECLINED"]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)

        let endpoint = Endpoints.Account.Credentials.Mandate.decline(credentialsId: "2")
        XCTAssertEqual(endpoint.path, "/apps/account/credentials/2/mandate")
        XCTAssertEqual(endpoint.method, .patch(jsonData))
        XCTAssertEqual(endpoint.environment, .production)
    }

    func testEnvironment() throws {
        var endpoint = Endpoints.Account.Credentials.Mandate.get(credentialsId: "1", onEnvironment: .staging)
        XCTAssertEqual(endpoint.environment, .staging)

        endpoint = Endpoints.Account.Credentials.Mandate.accept(credentialsId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Account.Credentials.Mandate.decline(credentialsId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Account.Credentials.Mandate.get(credentialsId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Account.Credentials.Mandate.accept(credentialsId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)

        endpoint = Endpoints.Account.Credentials.Mandate.decline(credentialsId: "1", onEnvironment: .development)
        XCTAssertEqual(endpoint.environment, .development)
    }

    func testState() throws {
        XCTAssertEqual(Account.Credentials.Mandate.State.pending.rawValue, "PENDING")
        XCTAssertEqual(Account.Credentials.Mandate.State.accepted.rawValue, "ACCEPTED")
        XCTAssertEqual(Account.Credentials.Mandate.State.declined.rawValue, "DECLINED")
    }

    func testEquatable() throws {
        let mandate1 = Account.Credentials.Mandate(state: .accepted, text: "foobar")
        let mandate2 = Account.Credentials.Mandate(state: .accepted, text: nil)
        let mandate3 = Account.Credentials.Mandate(state: .declined, text: "foobar")

        XCTAssertEqual(mandate1, mandate2)
        XCTAssertFalse(mandate3 == mandate2)
    }

    func testDecoder() throws {
        let data = try loadResource(filename: "mandate", withExtension: "json")
        let instance = try TestingDefaults.jsonDecoder.decode(Account.Credentials.Mandate.self, from: data)
        XCTAssertEqual(instance.state, .accepted)
        XCTAssertEqual(instance.text, "mandate text")
    }
}
