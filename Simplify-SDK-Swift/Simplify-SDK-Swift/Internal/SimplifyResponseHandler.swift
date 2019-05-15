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

class SimplifyResponseHandler {
    
    let jsonDecoder: JSONDecoderProtocol
    let completionHandler: (Result<SimplifyMap>) -> Void
    var logger: Logger
    
    init(jsonDecoder: JSONDecoderProtocol, logger: Logger = Logger(), _ handler: @escaping (Result<SimplifyMap>) -> Void) {
        self.jsonDecoder = jsonDecoder
        self.logger = logger
        completionHandler = handler
    }
    
    func receivedResponse(data: Data?, response: URLResponse?, error: Error?) {
        do {
            if let response = response {
                logger.logResponse(response, data: data)
            }
            let map = try interpretResponse(data: data, response: response, error: error)
            completionHandler(.success(map))
        } catch {
            completionHandler(.failure(error))
            return
        }
    }
}

extension SimplifyResponseHandler {
    private func interpretResponse(data: Data?, response: URLResponse?, error: Error?) throws -> SimplifyMap {
        // if connection errored, throw the error
        if let error = error {
            throw error
        }
        
        // verify that the request
        guard let status = (response as? HTTPURLResponse)?.statusCode else {
            throw SimplifyError("Non HTTP Response")
        }
        // attempt to parse the response payload
        var responseMap = SimplifyMap()
        if let data = data {
            responseMap = try jsonDecoder.decode(SimplifyMap.self, from: data)
        }
        
        // if the status is ok return the response payload
        if isStatusOk(status) {
            return responseMap
        }
        
        // throw an error
        let message = responseMap.error.message.stringValue ?? "An Error Occoured"
        throw SimplifyError(message, statusCode: status, errorResponse: responseMap)
    }
    
    private func isStatusOk(_ status: Int) -> Bool {
        return (200..<300).contains(status)
    }
}
