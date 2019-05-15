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

/// An Error object describing HTTP request failures when issuing requests against the Simplify API
public struct SimplifyError: Error, Equatable {
    
    /// A message explaining the failure
    public var message: String
    
    /// The HTTP Status code if it could be determined
    public var statusCode: Int?
    
    /// The failed response (if present) parsed as a SimplifyMap.
    public var errorResponse: SimplifyMap?
    
    /// Creates an instance of `SimplifyError`
    ///
    /// - Parameters:
    ///   - message: A message explaining the failure
    ///   - statusCode: HTTP Status (defaults to nil)
    ///   - errorResponse: The response payload (defaults to nil)
    init(_ message: String, statusCode: Int? = nil, errorResponse: SimplifyMap? = nil) {
        self.message = message
        self.statusCode = statusCode
        self.errorResponse = errorResponse
    }
}
