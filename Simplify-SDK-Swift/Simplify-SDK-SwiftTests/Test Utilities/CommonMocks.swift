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

import Foundation
import WebKit
@testable import Simplify

enum ReturnOrThrow<T> {
    case `return`(T)
    case `throw`(Error)
    
    init(_ value: T) {
        self = .return(value)
    }
    
    init(_ error: Error) {
        self = .throw(error)
    }
    
    func evaluate() throws -> T {
        switch self {
        case .return(let value):
            return value
        case .throw(let error):
            throw error
        }
    }
}

class JSONDecoderProtocolSpy: JSONDecoderProtocol {
    var wrapped: JSONDecoderProtocol = JSONDecoder()
    
    var decodeCalls: [(type: Decodable.Type, data: Data)] = []
    
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        decodeCalls.append((type: type, data: data))
        return try wrapped.decode(type, from: data)
    }
}

class JSONDecoderProtocolStub: JSONDecoderProtocol {
    enum Error: Swift.Error {
        case notStubbed
    }
    var decodeStub: ReturnOrThrow<Any> = ReturnOrThrow(Error.notStubbed)
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        return try decodeStub.evaluate() as! T
    }
}

class JSONEncoderProtocolSpy: JSONEncoderProtocol {
    var wrapped: JSONEncoderProtocol = JSONEncoder()
    
    var encodeCalls: [Any] = []
    func encode<T>(_ value: T) throws -> Data where T : Encodable {
        encodeCalls.append(value)
        return try wrapped.encode(value)
    }
}

class JSONEncoderProtocolStub: JSONEncoderProtocol {
    enum Error: Swift.Error {
        case notStubbed
    }
    
    var encodeStub: ReturnOrThrow<Data> = ReturnOrThrow(Error.notStubbed)
    func encode<T>(_ value: T) throws -> Data where T : Encodable {
        return try encodeStub.evaluate()
    }
}

class URLSessionProtocolSpy: URLSessionProtocol {
    var wrapped: URLSessionProtocol
    
    init(wrapping: URLSessionProtocol = URLSession(configuration: .default)) {
        self.wrapped = wrapping
    }
    
    typealias DataTaskCall = (request: URLRequest, completion: (Data?, URLResponse?, Error?) -> Void)
    var dataTaskCalls: [DataTaskCall] = []
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskCalls.append((request: request, completion: completionHandler))
        return wrapped.dataTask(with: request, completionHandler: completionHandler)
    }
    
}

class WebViewSpy: UIView, HTMLLoader {
    var wrapped: UIView & HTMLLoader
    
    init(wrapping: UIView & HTMLLoader = WKWebView()) {
        self.wrapped = wrapping
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.wrapped = WKWebView()
        super.init(coder: aDecoder)
    }
    
    typealias LoadHTMLCall = (html: String, baseURL: URL?)
    var loadHTMLStringCalls: [LoadHTMLCall] = []
    func loadHTMLString(_ html: String, baseURL: URL?) -> WKNavigation? {
        loadHTMLStringCalls.append((html: html, baseURL: baseURL))
        return wrapped.loadHTMLString(html, baseURL: baseURL)
    }
}
