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

class DecoratedTextFieldTests: XCTestCase {

    var testSubject = DecoratedTextField(frame: .zero)
    
    func testUnderlineColor_set() {
        testSubject.underlineColor = .blue
        XCTAssertEqual(testSubject.underlineView.backgroundColor, .blue)
    }
    
    func testUnderlineColor_get() {
        testSubject.underlineView.backgroundColor = .blue
        XCTAssertEqual(testSubject.underlineColor, .blue)
    }
    
    func testIconTintColor_set() {
        testSubject.iconTintColor = .green
        XCTAssertEqual(testSubject.iconView.tintColor, .green)
    }
    
    func testIconTintColor_get() {
        testSubject.iconView.tintColor = .green
        XCTAssertEqual(testSubject.iconTintColor, .green)
    }
    
    func testIcon_set() {
        testSubject.icon = testImage
        XCTAssertEqual(testSubject.iconView.image, testImage)
    }
    
    func testIcon_get() {
        testSubject.iconView.image = testImage
        XCTAssertEqual(testSubject.icon, testImage)
    }

}

extension DecoratedTextFieldTests {
    var testImage: UIImage {
        return UIImage(named: "testImage", in: Bundle(for: DecoratedTextFieldTests.self), compatibleWith: nil)!
    }
}
