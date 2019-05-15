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

class LuhnValidatorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMasterCardTestCardsLuhnPass() {
        XCTAssertTrue(LuhnValidator.validate("5555555555554444"))
        XCTAssertTrue(LuhnValidator.validate("2223577120017656"))
    }
    
    func testVisaTestCardsLuhnPass() {
        XCTAssertTrue(LuhnValidator.validate("4012888888881881"))
        XCTAssertTrue(LuhnValidator.validate("4111111111111111"))
    }
    
    func testDiscoverTestCardsLuhnPass() {
        XCTAssertTrue(LuhnValidator.validate("6011000990139424"))
        XCTAssertTrue(LuhnValidator.validate("6011111111111117"))
    }
    
    func testAmexTestCardsLuhnPass() {
        XCTAssertTrue(LuhnValidator.validate("371449635398431"))
        XCTAssertTrue(LuhnValidator.validate("378282246310005"))
    }
    
    func testDinersTestCardsLuhnPass() {
        XCTAssertTrue(LuhnValidator.validate("30569309025904"))
        XCTAssertTrue(LuhnValidator.validate("38520000023237"))
    }
    
    func testJCBTestCardsLuhnPass() {
        XCTAssertTrue(LuhnValidator.validate("3530111333300000"))
        XCTAssertTrue(LuhnValidator.validate("3566002020360505"))
    }
    
    func testRandomCardsLuhnFail() {
        XCTAssertFalse(LuhnValidator.validate("1234567890123456"))
        XCTAssertFalse(LuhnValidator.validate("1749365092798927"))
    }

}
