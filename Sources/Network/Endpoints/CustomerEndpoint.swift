//
//  CustomerEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2023-03-16.
//

import Foundation
import Combine

extension Endpoints {
    public enum Customer {
        public static func put(id: String, loyaltyCard: String, onEnvironment environment: Environment = .production) -> Endpoint<Customer> {
            .init(path: "/apps/customer",
                  method: .put(
                    data(forId: id, loyaltyCard: loyaltyCard)
                  ),
                  environment: environment
            )
        }
        // swiftlint:disable force_try
        private static func data(forId id: String, loyaltyCard: String) -> Data {
            let jsonObject = [
                "id": id,
                "loyaltyCard": loyaltyCard
            ]
            return try! JSONSerialization.data(withJSONObject: jsonObject)
        }
        // swiftlint:enable force_try
    }
}
