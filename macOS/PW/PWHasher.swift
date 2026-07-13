//
//  PWHasher.swift
//  pw26
//
//  Created with AI assistance on 2026-02-17.
//  Copyright © 2026 io.pwapp. All rights reserved.
//

import Foundation
import CommonCrypto

enum PWVersion: Int {
    case v1 = 0
    case v2 = 1
}

struct PWHasher {

    private static let specialChars: [Character] = Array("!@#$%^&*()-_=+~.")

    private static let emojiSet: [String] = [
        "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼",
        "🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔",
        "🌸", "🌺", "🌻", "🌹", "🌷", "🌵", "🌲", "🌴",
        "🍎", "🍊", "🍋", "🍇", "🍉", "🍓", "🍒", "🍑",
        "🍕", "🍔", "🍟", "🌮", "🍿", "🍩", "🍪", "🎂",
        "⚽", "🏀", "🎾", "🏈", "🎯", "🎮", "🎲", "🎸",
        "🚗", "🚀", "✈️", "🚂", "⛵", "🏠", "🏔️", "🌈",
        "⭐", "🌙", "☀️", "🔥", "💧", "❄️", "🎵", "💎"
    ]

    // MARK: - Public API

    static func hash(service: String, password: String, version: PWVersion) -> String {
        switch version {
        case .v1: return hashV1(service: service, password: password)
        case .v2: return hashV2(service: service, password: password)
        }
    }

    static func hashV1(service: String, password: String) -> String {
        let input = "\(normalize(service))||\(password)||"
        let hex = sha1(input)
        return uppercaseEvenIndices(hex)
    }

    static func hashV2(service: String, password: String) -> String {
        let input = "\(normalize(service))||\(password)||"
        let hex = sha256(input)
        let cased = uppercaseEvenIndices(hex)

        // Inject special char at position 3
        let firstChar = cased[cased.startIndex]
        let hexValue = hexDigitValue(firstChar)
        let special = specialChars[hexValue]

        var result = cased
        let insertIndex = result.index(result.startIndex, offsetBy: 3)
        result.insert(special, at: insertIndex)
        return String(result.prefix(40))
    }

    static func emojiCue(service: String, password: String) -> String {
        let input = "\(normalize(service))||\(password)||"
        let hex = sha256(input)
        // Use last 6 hex chars (indices 58-63) as 3 pairs
        let startIdx = hex.index(hex.endIndex, offsetBy: -6)
        let tail = String(hex[startIdx...])

        var emojis = ""
        for i in stride(from: 0, to: 6, by: 2) {
            let pairStart = tail.index(tail.startIndex, offsetBy: i)
            let pairEnd = tail.index(pairStart, offsetBy: 2)
            let pair = String(tail[pairStart..<pairEnd])
            let value = UInt8(pair, radix: 16) ?? 0
            let index = Int(value) % emojiSet.count
            emojis += emojiSet[index]
        }
        return emojis
    }

    // MARK: - Private helpers

    // Per the locked spec (README_ROADMAP.md): service is lowercased with all
    // spaces removed. The web app and the original simontabor/pw do the same;
    // hashing a spaced service without stripping breaks cross-platform output.
    private static func normalize(_ service: String) -> String {
        return service.lowercased().replacingOccurrences(of: " ", with: "")
    }

    private static func sha1(_ string: String) -> String {
        let data = Data(string.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA1(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func sha256(_ string: String) -> String {
        let data = Data(string.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func uppercaseEvenIndices(_ hex: String) -> String {
        var result = ""
        for (index, char) in hex.enumerated() {
            if index % 2 == 0 {
                result += String(char).uppercased()
            } else {
                result += String(char)
            }
        }
        return result
    }

    private static func hexDigitValue(_ char: Character) -> Int {
        let s = String(char).lowercased()
        if let v = Int(s, radix: 16) {
            return v
        }
        return 0
    }
}
