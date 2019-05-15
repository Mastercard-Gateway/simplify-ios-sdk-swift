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
import os

class Logger {
    func logRequest(_ request: URLRequest) {
        #if DEBUG
        var logMessage: String = "REQUEST: \(request.httpMethod ?? "-") \(request.url?.absoluteString ?? "-" )"
        if let data = request.httpBody {
            logMessage += "\n-- Data: \(String(data: data, encoding: .utf8) ?? data.base64EncodedString())"
        }
        for (key, value) in request.allHTTPHeaderFields ?? [:] {
            logMessage += "\n-- \(key): \(value)"
        }
        os_log(.debug, "%@", logMessage)
        #endif
    }
    
    func logResponse(_ response: URLResponse, data: Data?) {
        #if DEBUG
        let httpResponse = response as? HTTPURLResponse
        var logMessage: String = "RESPONSE: \(response.url?.absoluteString ?? "-" )"
        if let status = httpResponse?.statusCode {
            logMessage += "\n-- Status: \(status)"
        }
        if let data = data {
            logMessage += "\n-- Data: \(String(data: data, encoding: .utf8) ?? data.base64EncodedString())"
        }
        for (key, value) in httpResponse?.allHeaderFields ?? [:] {
            logMessage += "\n-- \(key): \(value)"
        }
        os_log(.debug, "%@", logMessage)
        #endif
    }
}
