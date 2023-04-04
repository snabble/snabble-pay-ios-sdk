//
//  AccountViewModel+Mandate.swift
//  SnabblePayExample
//
//  Created by Uwe Tilemann on 04.04.23.
//

import SwiftUI

extension AccountViewModel {
    var htmlText: String? {
        guard let mandateID = mandate?.id.rawValue,
              let html = UserDefaults.standard.object(forKey: mandateID) as? String else {
            return nil
        }
        return html
    }

    var markup: String? {
        guard let markup = htmlText,
              let body = markup.replacingOccurrences(of: "+", with: " ").removingPercentEncoding else {
            return nil
        }
        let head = """
<html>
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no" />
        <style type="text/css">
            pre { font-family: -apple-system, sans-serif; font-size: 15px; white-space: pre-wrap; }
            body { padding: 8px 8px }
            * { font-family: -apple-system, sans-serif; font-size: 15px; word-wrap: break-word }
            *, a { color: #000 }
            h1 { font-size: 22px }
            h2 { font-size: 17px }
            h4 { font-weight: normal; color: #3c3c43; opacity: 0.6 }
            @media (prefers-color-scheme: dark) {
                a, h4, * { color: #fff }
            }
        </style>
    </head>
    <body>
"""
        let trail = """
    </body>
</html>
"""
        return head + body + trail
    }
}

extension AccountViewModel {
    var mandateIDString: String {
        return mandate?.id.rawValue ?? ""
    }
    var mandateStateString: String {
        return NSLocalizedString(mandateState.rawValue, comment: "")
    }
    var mandateStateColor: Color {
        switch self.mandateState {
        case .missing, .pending:
            return Color.yellow
        case .accepted:
            return Color.green
        case .declined:
            return Color.red
        }
    }
    var mandateStateImage: Image {
        switch self.mandateState {
        case .missing, .pending:
            return Image(systemName: "questionmark.circle.fill")
        case .accepted:
            return Image(systemName: "checkmark.circle.fill")
        case .declined:
            return Image(systemName: "xmark.circle.fill")
        }
    }
}
