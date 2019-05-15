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

class CardEntryViewTests: XCTestCase {

    var testSubject = CardEntryView(frame: .zero)
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRendersCardNumber() {
        testSubject._model.number = "123456789"
        
        XCTAssertEqual(testSubject.numberField.text, testSubject._model.formattedCardNumber)
    }
    
    func testRendersCVC() {
        testSubject._model.cvc = "123"
        
        XCTAssertEqual(testSubject.cvcField.text, testSubject._model.cvc)
    }
    
    func testRendersFormattedExpiry() {
        testSubject._model.expiryMonth = 5
        testSubject._model.expiryYear = 19
        
        XCTAssertEqual(testSubject.expiryField.text, testSubject._model.expiryFormatted)
    }
    
    func testRendersExpiryEntryValues() {
        testSubject._model.currentYear = 10
        testSubject._model.currentMonth = 2
        testSubject._model.expiryMonth = 5
        testSubject._model.expiryYear = 19
        
        XCTAssertEqual(testSubject.expiryField.selectedYearIndex, testSubject._model.selectedExpiryYearIndex)
        XCTAssertEqual(testSubject.expiryField.selectedMonthIndex, testSubject._model.selectedExpiryMonthIndex)
        XCTAssertEqual(testSubject.expiryField.monthSelectionTitles, testSubject._model.expiryMonthTitles)
        XCTAssertEqual(testSubject.expiryField.yearSelectionTitles, testSubject._model.expiryYearTitles)
    }
    
    func testPopulatesNumberToViewModel() {
        testSubject.numberField.text = "134679"
        testSubject.numberChanged(self)
        
        XCTAssertEqual(testSubject._model.number, "134679")
    }
    
    func testPopulatesCvcToViewModel() {
        testSubject.cvcField.text = "123"
        testSubject.cvcChanged(self)
        
        XCTAssertEqual(testSubject._model.cvc, "123")
    }
    
    func testPopulatesExpirySelectionToViewModel() {
        testSubject.expiryField.selectedMonthIndex = 2
        testSubject.expiryField.selectedYearIndex = 5
        testSubject.expiryChanged(self)
        
        XCTAssertEqual(testSubject._model.selectedExpiryMonthIndex, 2)
        XCTAssertEqual(testSubject._model.selectedExpiryYearIndex, 5)
    }
    
    func testNumberPlacholderGet() {
        testSubject.numberField.placeholder = "cnpGet"
        XCTAssertEqual(testSubject.cardNumberPlaceholderText, "cnpGet")
    }
    
    func testNumberPlacholderSet() {
        testSubject.cardNumberPlaceholderText = "cnpSet"
        XCTAssertEqual(testSubject.numberField.placeholder, "cnpSet")
    }
    
    func testExpiryPlacholderGet() {
        testSubject.expiryField.placeholder = "epGet"
        XCTAssertEqual(testSubject.cardExpiryPlaceholderText, "epGet")
    }
    
    func testExpiryPlacholderSet() {
        testSubject.cardExpiryPlaceholderText = "epSet"
        XCTAssertEqual(testSubject.expiryField.placeholder, "epSet")
    }
    
    func testCvcPlacholderGet() {
        testSubject.cvcField.placeholder = "cvcpGet"
        XCTAssertEqual(testSubject.cardCvcPlaceholderText, "cvcpGet")
    }
    
    func testCvcPlacholderSet() {
        testSubject.cardCvcPlaceholderText = "cvcpSet"
        XCTAssertEqual(testSubject.cvcField.placeholder, "cvcpSet")
    }
    
    func testExpiryEditingBegan() {
        testSubject._model.currentYear = 10
        testSubject._model.currentMonth = 2
        
        testSubject.expiryEditingBegan(self)

        XCTAssertEqual(testSubject.expiryField.text, "02/10")
    }
    
    func testGetCardFromVM() {
        testSubject._model.number = "123456789"
        testSubject._model.cvc = "456"
        testSubject._model.expiryYear = 23
        testSubject._model.expiryMonth = 12
        
        XCTAssertEqual(testSubject.card, testSubject._model.card)
        XCTAssertEqual(testSubject.isValid, testSubject._model.cardValid)
    }

}
