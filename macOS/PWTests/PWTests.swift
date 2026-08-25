//
//  PWTests.swift
//  PWTests
//
//  Created by hugh on 04/03/2016.
//  Copyright © 2016 hugh. All rights reserved.
//

import XCTest
@testable import PW

class PWTests: XCTestCase {

    // MARK: - Password output privacy

    func testPartiallyMaskedOutput_hidesLastThreeQuarters() {
        let password = "0123456789abcdefghijklmnopqrstuvwxyzABCD"
        let displayed = PasswordOutputDisplay.partiallyMasked(password)

        XCTAssertEqual(displayed, "0123456789" + String(repeating: "•", count: 30))
        XCTAssertEqual(displayed.count, password.count)
    }

    func testPartiallyMaskedOutput_emptyPasswordStaysEmpty() {
        XCTAssertEqual(PasswordOutputDisplay.partiallyMasked(""), "")
    }

    // MARK: - V1 Tests

    func testV1_facebookHackference() {
        let result = PWHasher.hashV1(service: "facebook", password: "hackference")
        XCTAssertEqual(result, "762b679fA17b10D6Cc2d2194542d2235738b3e33")
        XCTAssertEqual(result.count, 40)
    }

    func testV1_emptyInputs() {
        let result = PWHasher.hashV1(service: "", password: "")
        XCTAssertEqual(result.count, 40)
    }

    // MARK: - V2 Tests

    func testV2_facebookHackference_fullOutput() {
        let result = PWHasher.hashV2(service: "facebook", password: "hackference")
        XCTAssertEqual(result, "FfD.07fCb7c1869AcA60d9d31D3C58bEaFc82D01")
        XCTAssertEqual(result.count, 40)
    }

    func testV2_facebookHackference_first15() {
        let result = PWHasher.hashV2(service: "facebook", password: "hackference")
        let first15 = String(result.prefix(15))
        XCTAssertEqual(first15, "FfD.07fCb7c1869")
    }

    func testV2_specialCharAtPosition3() {
        let result = PWHasher.hashV2(service: "facebook", password: "hackference")
        let charAtPos3 = result[result.index(result.startIndex, offsetBy: 3)]
        let specialChars = "!@#$%^&*()-_=+~."
        XCTAssertTrue(specialChars.contains(charAtPos3), "Character at position 3 should be a special character, got: \(charAtPos3)")
    }

    func testV2_first15_containsRequiredCharTypes() {
        let result = PWHasher.hashV2(service: "facebook", password: "hackference")
        let first15 = String(result.prefix(15))

        let hasUpper = first15.contains(where: { $0.isUppercase })
        let hasLower = first15.contains(where: { $0.isLowercase })
        let hasDigit = first15.contains(where: { $0.isNumber })
        let hasSpecial = first15.contains(where: { "!@#$%^&*()-_=+~.".contains($0) })

        XCTAssertTrue(hasUpper, "First 15 chars should contain uppercase")
        XCTAssertTrue(hasLower, "First 15 chars should contain lowercase")
        XCTAssertTrue(hasDigit, "First 15 chars should contain digit")
        XCTAssertTrue(hasSpecial, "First 15 chars should contain special char")
    }

    // MARK: - Emoji Tests

    func testEmojiCue_returns3Emoji() {
        let emoji = PWHasher.emojiCue(service: "facebook", password: "hackference")
        XCTAssertEqual(emoji.count, 3, "Emoji cue should be exactly 3 emoji")
    }

    func testEmojiCue_deterministic() {
        let emoji1 = PWHasher.emojiCue(service: "facebook", password: "hackference")
        let emoji2 = PWHasher.emojiCue(service: "facebook", password: "hackference")
        XCTAssertEqual(emoji1, emoji2)
    }

    // MARK: - Service normalization (locked spec: lowercased, spaces removed)

    func testV1_serviceSpacesStripped() {
        let spaced = PWHasher.hashV1(service: "face book", password: "hackference")
        XCTAssertEqual(spaced, "762b679fA17b10D6Cc2d2194542d2235738b3e33",
                       "Spaces in service must be stripped to match web and the original pw")
    }

    func testV2_serviceSpacesStripped() {
        let spaced = PWHasher.hashV2(service: "FACE BOOK", password: "hackference")
        let plain = PWHasher.hashV2(service: "facebook", password: "hackference")
        XCTAssertEqual(spaced, plain)
    }

    func testEmojiCue_serviceSpacesStripped() {
        let spaced = PWHasher.emojiCue(service: "face book", password: "hackference")
        let plain = PWHasher.emojiCue(service: "facebook", password: "hackference")
        XCTAssertEqual(spaced, plain, "Emoji cue must use the same normalized service as the hash")
    }

    // MARK: - Cross-platform consistency

    func testV1_matchesIOS() {
        // Same test vector as iOS - ensures both platforms produce identical output
        let result = PWHasher.hashV1(service: "facebook", password: "hackference")
        XCTAssertEqual(result, "762b679fA17b10D6Cc2d2194542d2235738b3e33")
    }

    func testV2_matchesIOS() {
        let result = PWHasher.hashV2(service: "facebook", password: "hackference")
        XCTAssertEqual(result, "FfD.07fCb7c1869AcA60d9d31D3C58bEaFc82D01")
    }
}
