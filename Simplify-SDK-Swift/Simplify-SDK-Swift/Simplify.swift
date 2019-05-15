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

import UIKit

/// The primary object for interacting with Simplify APIs.
public class Simplify {
    let apiKey: String
    let device: UIDevice
    var logger: Logger = Logger()
    
    lazy var urlSessionDelegate: URLSessionDelegate? = lazyCertificatePinningDelegate()
    lazy var urlSession: URLSessionProtocol = lazyURLSession()
    lazy var jsonEncoder: JSONEncoderProtocol = lazyJSONEncoder()
    lazy var jsonDecoder: JSONDecoderProtocol = lazyJSONDecoder()
    
    // Internal initializer
    init(apiKey: String, device: UIDevice) throws {
        guard Simplify.validateApiKey(apiKey) else { throw SimplifyError("Invalid API Key") }
        self.apiKey = apiKey
        self.device = device
    }
    
    /// Creates an instance of Simplify to make requests to the Simplify API for the purpose of creating card tokens.
    ///
    /// - Parameters:
    ///   - apiKey: A `live` or `sandbox` Simplify Public API Key
    /// - Throws: A `SimplifyError` if the API key is invalid
    public convenience init(apiKey: String) throws {
        try self.init(apiKey: apiKey, device: .current)
    }
    
    /// Create a Card Token for use with the Simplify API
    ///
    /// - Parameters:
    ///   - card: An instance of a `SimplifyMap` containing the card object.
    ///   - secure3DRequestData: An instance of `SimplifyMap` with the "ammount", "currency" and "description" of the transaction
    ///   - completion: Called with a `Result` object containing a `SimplifyMap` of the card token on success or an `Error` on failure
    public func createCardToken(card: SimplifyMap, secure3DRequestData: SimplifyMap? = nil, completion: @escaping (Result<SimplifyMap>) -> Void) {
        do {
            let request = try buildCreateCardTokenRequest(card: card, secure3DRequestData: secure3DRequestData)
            let responseHandler = SimplifyResponseHandler(jsonDecoder: jsonDecoder, logger: logger, completion)
            logger.logRequest(request)
            let task = urlSession.dataTask(with: request, completionHandler: responseHandler.receivedResponse(data:response:error:))
            task.resume()
        } catch {
            // defer calling completion to ensure the function returns first thus preserving the natural async order.
            defer { completion(.failure(error)) }
            return
        }
    }
}

