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

class SimplifyResponseHandlerTests: XCTestCase {
    var testSubject: SimplifyResponseHandler!
    
    var latestResult: Result<SimplifyMap>? = nil
    
    lazy var decoderStub = JSONDecoderProtocolStub()
    lazy var decoderSpy = JSONDecoderProtocolSpy()
    
    var validResponse = HTTPURLResponse(url: URL(string: "https://mastercard.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
    var invalidResponse = HTTPURLResponse(url: URL(string: "https://mastercard.com")!, statusCode: 301, httpVersion: nil, headerFields: nil)
    var errorResponseData = """
        {
            "error" : {
                "message" : "Oops"
            }
        }
        """.data(using: .utf8)!
    
    var validResponseData = """
        {
            "status" : "good"
        }
        """.data(using: .utf8)!
    
    
    override func setUp() {
        decoderSpy.wrapped = decoderStub
        testSubject = SimplifyResponseHandler(jsonDecoder: decoderSpy, { (result) in
            self.latestResult = result
        })
    }

    override func tearDown() {
    }

    func testErrorResponse_FailsWithError() {
        testSubject.receivedResponse(data: nil, response: nil, error: MockError.requestError)
        
        assertFailure(latestResult, equalTo: MockError.requestError)
    }
    
    func testNonHTTPResponse_FailsWithSimplifyError() {
        testSubject.receivedResponse(data: nil, response: nil, error: nil)
        
        assertFailure(latestResult, equalTo: SimplifyError("Non HTTP Response"))
    }
    
    func testDecodingError_FailsWithError() {
        decoderStub.decodeStub = ReturnOrThrow(MockError.decodingError)
        
        testSubject.receivedResponse(data: Data(), response: validResponse, error: nil)
        
        assertFailure(latestResult, equalTo: MockError.decodingError)
    }
    
    func testOKStatus_OKDecode_ReturnsMap() {
        let goodResponse = SimplifyMap(["status" : "good"])!
        decoderStub.decodeStub = ReturnOrThrow(goodResponse)
        
        testSubject.receivedResponse(data: Data(), response: validResponse, error: nil)
        
        assertSuccess(latestResult, equalTo: goodResponse)
    }
    
    func testBadStatus_ErrorDecode_ReturnsMessage() {
        let errorResponse = SimplifyMap(["error" : ["message" : "bad things"]])
        decoderStub.decodeStub = ReturnOrThrow(errorResponse as Any)
        
        testSubject.receivedResponse(data: Data(), response: invalidResponse, error: nil)
        
        assertFailure(latestResult, equalTo: SimplifyError("bad things", statusCode: 301, errorResponse: errorResponse))
    }
    
    func testResponseData_decodedAsMap() {
        testSubject.receivedResponse(data: validResponseData, response: validResponse, error: nil)
        
        XCTAssertEqual(decoderSpy.decodeCalls.count, 1)
        let decodeCall = decoderSpy.decodeCalls.first!
        XCTAssertEqual(decodeCall.data, validResponseData)
        switch decodeCall.type {
        case is SimplifyMap.Type:
           break
        default:
            XCTFail("Attemptint to decode payload of wrong type")
        }
    }

}

extension SimplifyResponseHandlerTests {
    enum MockError: Error {
        case requestError
        case decodingError
    }
    
    fileprivate func assertFailure<T: Error & Equatable>(_ result: Result<SimplifyMap>?, equalTo expected: T, file: StaticString = #file, line: UInt = #line, function: String = #function) {
        switch latestResult {
        case .failure(let error)?:
            if expected != (error as? T) {
                XCTFail("\(error) not equal to \(expected)", file: file, line: line)
            }
        default:
            XCTFail("Unexpected success", file: file, line: line)
        }
    }
    
    
    fileprivate func assertSuccess(_ result: Result<SimplifyMap>?, equalTo expected: SimplifyMap, file: StaticString = #file, line: UInt = #line, function: String = #function) {
        switch latestResult {
        case .success(let map)?:
            if expected != map {
                XCTFail("\(map) not equal to \(expected)", file: file, line: line)
            }
        default:
            XCTFail("Unexpected failure", file: file, line: line)
        }
    }
}
