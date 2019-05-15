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

class SimplifyTests: XCTestCase {
    
    var testSubject: Simplify!
    
    var urlSessionSpy: URLSessionProtocolSpy!
    
    let validSandboxKey = "sbpb_N2Q3OTU1MTctYWE1OS00MTNkLWE0NzctZTI0YWE2NjRmZmEz"
    let validLiveKey = "lvpb_N2Q3OTU1MTctYWE1OS00MTNkLWE0NzctZTI0YWE2NjRmZmEz"
    let invalidKey = "sbxbN2Q3OTU1MTctYWE1OS00MTNkLWE0NzctZTI0YWE2NjRmZmEz"
    
    override func setUp() {
        
    }

    func testInitValidAPIKey() {
        XCTAssertNoThrow(try Simplify(apiKey: validLiveKey))
        XCTAssertNoThrow(try Simplify(apiKey: validSandboxKey))
    }
    
    func testInitInvalidAPIKey() {
        XCTAssertThrowsError(try Simplify(apiKey: invalidKey))
    }
    
    func testCreateCardToken_usesLiveURL() {
        setup(with: validLiveKey)
        
        testSubject.createCardToken(card: SimplifyMap()) { (_) in }
        
        let call = validateSingleCall()
        XCTAssertEqual(call.request.url, URL(string: "https://api.simplify.com/v1/api/payment/cardToken")!)
    }
    
    func testCreateCardToken_usesSandboxURL() {
        setup(with: validSandboxKey)
        
        testSubject.createCardToken(card: SimplifyMap()) { (_) in }
        
        let call = validateSingleCall()
        XCTAssertEqual(call.request.url, URL(string: "https://sandbox.simplify.com/v1/api/payment/cardToken")!)
    }
    
    func testCreateCardToken_usesPOSTMethod() {
        setup(with: validSandboxKey)
        
        testSubject.createCardToken(card: SimplifyMap()) { (_) in }
        
        let call = validateSingleCall()
        XCTAssertEqual(call.request.httpMethod, "POST")
    }
    
    func testCreateCardToken_populatesContentType() {
        setup(with: validSandboxKey)
        
        testSubject.createCardToken(card: SimplifyMap()) { (_) in }
        
        let call = validateSingleCall()
        XCTAssertEqual(call.request.allHTTPHeaderFields?["Content-Type"], "application/json")
    }
    
    func testCreateCardToken_populatesUserAgent() {
        setup(with: validSandboxKey)
        
        testSubject.createCardToken(card: SimplifyMap()) { (_) in }
        
        let userAgent = validateSingleCall().request.allHTTPHeaderFields?["User-Agent"]
        XCTAssertNotNil(userAgent)
        XCTAssertNotNil(userAgent!.range(of: "iOS-SDK/([0-9]+(\\.[0-9]+)*) \\( .* \\)", options: .regularExpression))
    }
    
    func testCreateCardToken_UnableToEncodeThrows() {
        let stubEncoder = JSONEncoderProtocolStub()
        stubEncoder.encodeStub = ReturnOrThrow<Data>(TestError.stubError)
        
        setup(with: validSandboxKey)
        testSubject.jsonEncoder = stubEncoder
        
        var callResult: Result<SimplifyMap>?
        
        testSubject.createCardToken(card: SimplifyMap()) { callResult = $0 }
        
        switch callResult {
        case .failure(let error)?:
            if TestError.stubError != (error as? TestError) {
                XCTFail("\(error) not Error.stubError")
            }
        default:
            XCTFail("Unexpected success")
        }
    }
}

extension SimplifyTests {
    fileprivate func setup(with key: String) {
        testSubject = try! Simplify(apiKey: key)
        urlSessionSpy = URLSessionProtocolSpy()
        testSubject.urlSession = urlSessionSpy
    }
    
    fileprivate func validateSingleCall(file: StaticString = #file, line: UInt = #line) -> (request: URLRequest, completion: (Data?, URLResponse?, Error?) -> Void) {
        if urlSessionSpy.dataTaskCalls.count != 1 {
            XCTFail("dataTask was not called exactly once", file: file, line: line)
        }
        return urlSessionSpy.dataTaskCalls.first!
    }
    
    enum TestError: Swift.Error {
        case stubError
    }
}
