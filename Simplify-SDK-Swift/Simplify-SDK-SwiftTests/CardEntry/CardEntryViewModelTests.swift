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

class CardEntryViewModelTests: XCTestCase {
    var testSubject = CardEntryViewModel()
    
    override func setUp() {
    }

    override func tearDown() {
    }
    
    func testInitWithCurrentMonthAndYear() {
        testSubject = CardEntryViewModel(currentYear: 05, currentMonth: 10)
        XCTAssertEqual(testSubject.currentYear, 05)
        XCTAssertEqual(testSubject.currentMonth, 10)
    }
    
    func testInitWithDate() {
        testSubject = CardEntryViewModel(current: Date(timeIntervalSince1970: 1556646913), calendar: .current)
        XCTAssertEqual(testSubject.currentYear, 19)
        XCTAssertEqual(testSubject.currentMonth, 4)
    }

    func testCardEntryViewModel_CardMap() {
        testSubject.number = "5555555555554444"
        testSubject.expiryYear = 19
        testSubject.expiryMonth = 6
        testSubject.cvc = "123"
        
        XCTAssertEqual(testSubject.card, .map(["number" : .string("5555555555554444"), "expYear" : .int(19), "expMonth" : .int(6), "cvc" : .string("123")]))
    }
    
    func testSettingFormattedCardNumber_normalizes() {
        testSubject.formattedCardNumber = "5555 5555 5555 4444"
        XCTAssertEqual(testSubject.number, "5555555555554444")
    }
    
    func testSettingFormattedCardNumber_nil() {
        testSubject.formattedCardNumber = nil
        XCTAssertNil(testSubject.number)
    }
    
    func testExpiryFormtting_NilMonth() {
        testSubject.expiryYear = 19
        XCTAssertNil(testSubject.expiryFormatted)
    }
    
    func testExpiryFormtting_NilYear() {
        testSubject.expiryMonth = 1
        XCTAssertNil(testSubject.expiryFormatted)
    }
    
    func testExpiryFormtting() {
        testSubject.expiryYear = 19
        testSubject.expiryMonth = 1
        XCTAssertEqual(testSubject.expiryFormatted, "01/19")
    }
    
    func testExpiryMonthTitles() {
        // set the locale to test in
        testSubject.expiryFormatter.locale = Locale(identifier: "en_US")
        
        XCTAssertEqual(testSubject.expiryMonthTitles, ["Jan(1)", "Feb(2)", "Mar(3)", "Apr(4)", "May(5)", "Jun(6)", "Jul(7)", "Aug(8)", "Sep(9)", "Oct(10)", "Nov(11)", "Dec(12)"])
    }
    
    func testExpiryYearTitles() {
        testSubject.currentYear = 19
        XCTAssertEqual(testSubject.expiryYearTitles, ["2019", "2020", "2021", "2022", "2023", "2024", "2025", "2026", "2027", "2028", "2029", "2030", "2031", "2032", "2033", "2034", "2035", "2036", "2037", "2038"])
    }
    
    func testGetSelectedExpiryYear_validIndex() {
        testSubject.currentYear = 19
        testSubject.expiryYear = 23
        
        XCTAssertEqual(testSubject.selectedExpiryYearIndex, 4)
    }
    
    func testGetSelectedExpiryYear_Default() {
        testSubject.currentYear = 19
        
        XCTAssertEqual(testSubject.selectedExpiryYearIndex, 0)
    }
    
    func testGetSelectedExpiryYear_ValueNotInOptions() {
        testSubject.currentYear = 0
        testSubject.expiryYear = 23
        
        XCTAssertEqual(testSubject.selectedExpiryYearIndex, 0)
    }
    
    func testSetSelectedExpiryYearIndex() {
        testSubject.currentYear = 19
        testSubject.selectedExpiryYearIndex = 6
        
        XCTAssertEqual(testSubject.expiryYear, 25)
    }
    
    func testGetSelectedExpiryMonth_validIndex() {
        testSubject.expiryMonth = 6
        
        XCTAssertEqual(testSubject.selectedExpiryMonthIndex, 5)
    }
    
    func testGetSelectedExpiryMonth_Default() {
        testSubject.currentMonth = 4
        
        XCTAssertEqual(testSubject.selectedExpiryMonthIndex, 3)
    }
    
    func testGetSelectedExpiryMonth_ValueNotInOptions() {
        testSubject.currentMonth = 2
        testSubject.expiryMonth = 13
        
        XCTAssertEqual(testSubject.selectedExpiryMonthIndex, 0)
    }
    
    func testSetSelectedExpiryMonthIndex() {
        testSubject.selectedExpiryMonthIndex = 6
        
        XCTAssertEqual(testSubject.expiryMonth, 7)
    }
    
    func testSetExpiryDefaultOnEditingBegin() {
        testSubject.currentMonth = 1
        testSubject.currentYear = 19
        
        testSubject.initiateExpiryEditing()
        
        
        XCTAssertEqual(testSubject.expiryMonth, 1)
        XCTAssertEqual(testSubject.expiryYear, 19)
    }
    
    func testInvalidCardNumber() {
        testSubject.number = "5555666677778888"
        XCTAssertFalse(testSubject.numberValid)
        XCTAssertFalse(testSubject.cardValid)
    }
    
    func testInvalidCVC() {
        testSubject.number = "5555555555554444"
        testSubject.cvc = "12345"
        XCTAssertFalse(testSubject.cvcValid)
        XCTAssertFalse(testSubject.cardValid)
    }
    
    func testInvalidExpiry() {
        testSubject.number = "5555555555554444"
        testSubject.cvc = "123"
        testSubject.currentYear = 19
        testSubject.currentMonth = 5
        testSubject.expiryYear = 19
        testSubject.expiryMonth = 4
        XCTAssertFalse(testSubject.expiryValid)
        XCTAssertFalse(testSubject.cardValid)
    }
    
    func testValidCard() {
        testSubject.number = "5555555555554444"
        testSubject.cvc = "123"
        testSubject.currentYear = 19
        testSubject.currentMonth = 5
        testSubject.expiryYear = 20
        testSubject.expiryMonth = 4

        XCTAssertTrue(testSubject.cvcValid)
        XCTAssertTrue(testSubject.numberValid)
        XCTAssertTrue(testSubject.expiryValid)
        XCTAssertTrue(testSubject.cardValid)
    }
}
