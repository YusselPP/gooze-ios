//
//  String+Extension.swift
//  Gooze
//
//  Created by Yussel on 1/24/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

extension String {
    func addQuotes() -> String {
        return "\"" + self + "\""
    }

    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }

    func size(font: UIFont) -> CGSize {
        let nsString = self as NSString
        return nsString.size(withAttributes: [NSAttributedString.Key.font: font])
    }

    func matches(pattern: String) -> Bool {
        return self.range(of: pattern, options: .regularExpression) != nil
    }

    func luhnCheck() -> Bool {
        var sum = 0
        let reversedCharacters = self.reversed().map { String($0) }
        for (idx, element) in reversedCharacters.enumerated() {
            guard let digit = Int(element) else { return false }
            switch ((idx % 2 == 1), digit) {
            case (true, 9): sum += 9
            case (true, 0...8): sum += (digit * 2) % 9
            default: sum += digit
            }
        }
        return sum % 10 == 0
    }

    func cardNumberFormat(reverse: Bool = false) -> String {
        let string = self

        var formattedString = ""
        let normalizedString = (
            String(string.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
                .prefix(16))
        )

        if reverse {
            formattedString = normalizedString
        } else {
            var idx = 0
            var character: Character
            while idx < normalizedString.count {
                let index = normalizedString.index(normalizedString.startIndex, offsetBy: idx)
                character = normalizedString[index]

                if idx != 0 && idx % 4 == 0 {
                    formattedString.append(" ")
                }

                formattedString.append(character)
                idx += 1
            }
        }

        return formattedString
    }
}
