/*
 Copyright (c) 2017 Mastercard
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import XCTest
@testable import Simplify

class CardBrandDetailsTests: XCTestCase {

    var testSubject: CardBrand.Details!
    
    override func setUp() {
        testSubject = CardBrand.Details(icon: nil, validLengths: [16, 19], cvcLength: 4, prefixPattern: "^(?:5[2-5])\\d*", formatter: CardBrand.Details.formatterGroupFours)
    }

    override func tearDown() {
        
    }

    func testGroupFourFormatting() {
        XCTAssertEqual(CardBrand.Details.formatterGroupFours("1234567890"), "1234 5678 90") // partial number
        XCTAssertEqual(CardBrand.Details.formatterGroupFours("1234567890123456"), "1234 5678 9012 3456")
    }
    
    func testAmexFormatting() {
        XCTAssertEqual(CardBrand.Details.formatterAmex("371449635398431"), "3714 496353 98431")
        XCTAssertEqual(CardBrand.Details.formatterAmex("3714496"), "3714 496") // partial number
    }
    
    func testPrefixPatternMatches() {
        XCTAssertTrue(testSubject.prefixMatches("55587678660876"))
        XCTAssertTrue(testSubject.prefixMatches("555555587678660876"))
    }
    
    func testPrefixPatternDoesNotMatch() {
        XCTAssertFalse(testSubject.prefixMatches("587678660876"))
        XCTAssertFalse(testSubject.prefixMatches("1234567890"))
    }
    
    func testCardLenghValidationMatches() {
        XCTAssertTrue(testSubject.validateLength(cardNumber: "1234567890123456"))
        XCTAssertTrue(testSubject.validateLength(cardNumber: "1234567890123456789"))
    }
    
    func testCardLenghDoesNotMatch() {
        XCTAssertFalse(testSubject.validateLength(cardNumber: "123456789012345"))
        XCTAssertFalse(testSubject.validateLength(cardNumber: "123456789012345678"))
        XCTAssertFalse(testSubject.validateLength(cardNumber: "12345678901234567890"))
    }

}
