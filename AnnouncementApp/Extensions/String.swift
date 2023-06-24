//
//  String.swift
//  IA3V2
//
//  Created by James Nunn on 31/5/2023.
//

import Foundation
extension String {
    func isValidEmail() -> Bool {
        /// https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift by Arsonik
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    func containsProfanity() -> Bool{
        let lowercasedString = self.lowercased()
        let words = BadWordClass().words
        for word in words {
            if lowercasedString.contains(word) {
                return true
            }
        }
        return false
    }
}

