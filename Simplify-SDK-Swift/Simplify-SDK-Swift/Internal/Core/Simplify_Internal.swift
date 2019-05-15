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

// MARK: - Nested Classes
extension Simplify {
    // constants needed by the Simplify object
    internal struct Constants {
        static let apiBaseLiveURL = "https://api.simplify.com/v1/api"
        static let apiBaseSandboxURL = "https://sandbox.simplify.com/v1/api"
        static let apiPathCardToken = "/payment/cardToken"
        static let patternApiKey = "(?:lv|sb)pb_(.+)"
        static let liveKeyPrefix = "lvpb_"
        static let httpMethodPost = "POST"
        
        static let contentTypeHeader = "Content-Type"
        static let userAgentHeader = "User-Agent"
        static let jsonContentType = "application/json"
    }
}

// MARK: - Helpers
extension Simplify {
    var userAgent: String {
        // build a string of additional device and bundle information
        var additionalData: [String: String] = ["Device" : device.model, "OS" : device.systemVersion]
        additionalData["Bundle"] = Bundle.main.bundleIdentifier
        let additionalDataString = additionalData.map { return "\($0.key): \($0.value)" }.joined(separator: "; ")
        
        return "iOS-SDK/\(BuildConfig.sdkVersion) ( \(additionalDataString) )"
    }
    
    var isLive: Bool {
        return apiKey.hasPrefix(Constants.liveKeyPrefix)
    }
    
    var urlString: String {
        return isLive ? Constants.apiBaseLiveURL : Constants.apiBaseSandboxURL
    }
    
    var url: URL {
        // given that we know the two URLS which we have defined as constants are known to produce valid URLs, we will force unwrap the optional
        return URL(string: urlString)!
    }
    
    func buildCreateCardTokenRequest(card: SimplifyMap, secure3DRequestData: SimplifyMap?) throws -> URLRequest {
        var payload = SimplifyMap()
        payload.card = card
        payload.key.value = apiKey
        if let secure3DRequestData = secure3DRequestData {
            payload.secure3DRequestData = secure3DRequestData
        }
        
        var request = URLRequest(url: url.appendingPathComponent(Constants.apiPathCardToken))
        request.httpMethod = Constants.httpMethodPost
        request.httpBody = try jsonEncoder.encode(payload)
        
        request.addValue(userAgent, forHTTPHeaderField: Constants.userAgentHeader)
        request.addValue(Constants.jsonContentType, forHTTPHeaderField: Constants.contentTypeHeader)
        
        return request
    }
    
    static func validateApiKey(_ key: String) -> Bool {
        return key.range(of: Constants.patternApiKey, options: .regularExpression) != nil
    }
}


// MARK: - Lazy property constructors
extension Simplify {
    func lazyCertificatePinningDelegate() -> URLSessionDelegate {
        let delegate = URLSessionPinner()
        // set the intermediate CA strings from the build config
        delegate.trustedCertificates = BuildConfig.intermidateCaStrings
        
        return delegate
    }
    
    func lazyURLSession() -> URLSessionProtocol {
        let session = URLSession(configuration: .ephemeral)
        return session
    }
    
    func lazyJSONEncoder() -> JSONEncoderProtocol {
        return JSONEncoder()
    }
    
    func lazyJSONDecoder() -> JSONDecoderProtocol {
        return JSONDecoder()
    }
}
