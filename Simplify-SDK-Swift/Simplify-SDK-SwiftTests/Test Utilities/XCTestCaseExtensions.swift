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

extension XCTestCase {
    func XCTAssertContains<T: Equatable>(_ array: Array<T>, _ element: T, file: StaticString = #file, line: UInt = #line){
        if !array.contains(element) {
            XCTFail("Array does not contain \(String(describing: element))", file: file, line: line)
        }
    }
    
    func XCTassertThrowsError<T, E: Equatable & Error>(_ expression: @autoclosure () throws -> T, equalTo expected: E, file: StaticString = #file, line: UInt = #line) {
        do {
            _ = try expression()
            XCTFail("Expected expression to throw \(String(describing: E.self))", file: file, line: line)
        } catch {
            if let e = error as? E, e == expected {
                return
            }
            XCTFail("Error thrown \(error) does not match expected error of \(expected)", file: file, line: line)
        }
    }
}

