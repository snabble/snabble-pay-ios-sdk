//
//  AccountStateTests.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-25.
//

import XCTest
@testable import SnabblePayNetwork

final class AccountStateTests: XCTestCase {

    var account1: Account!
    var account2: Account!

    override func setUpWithError() throws {
        var data = try loadResource(filename: "account-empty", withExtension: "json")
        account1 = try TestingDefaults.jsonDecoder.decode(Account.self, from: data)

        data = try loadResource(filename: "account-one", withExtension: "json")
        account2 = try TestingDefaults.jsonDecoder.decode(Account.self, from: data)
    }

    func testState() throws {
        XCTAssertEqual(account1.state, .pending)
        XCTAssertEqual(account2.state, .ready)
    }
}
