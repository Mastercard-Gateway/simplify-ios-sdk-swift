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

enum CardBrand: String {
    case visa = "VISA"
    case mastercard = "MASTERCARD"
    case americanExpress = "AMERICAN_EXPRESS"
    case discover = "DISCOVER"
    case diners = "DINERS"
    case jcb = "JCB"
    case unknown = "UNKNOWN"
}

extension CardBrand {
    var details: Details {
        switch self {
        case .visa:
            return Details(icon: UIImage(named: "visa", in: .simplifySDK, compatibleWith: nil), validLengths: [13, 16, 19], cvcLength: 3, prefixPattern: "^4\\d*")
        case .mastercard:
            return Details(icon: UIImage(named: "mastercard", in: .simplifySDK, compatibleWith: nil), validLengths: [16], cvcLength: 3, prefixPattern: "^(?:5[1-5]|67)\\d*")
        case .americanExpress:
            return Details(icon: UIImage(named: "amex", in: .simplifySDK, compatibleWith: nil), validLengths: [15], cvcLength: 4, prefixPattern: "^3[47]\\d*", formatter: Details.formatterAmex)
        case .discover:
            return Details(icon: UIImage(named: "discover", in: .simplifySDK, compatibleWith: nil), validLengths: [16, 17, 18, 19], cvcLength: 3, prefixPattern: "^6(?:011|4[4-9]|5)\\d*")
        case .diners:
            return Details(icon: UIImage(named: "diners", in: .simplifySDK, compatibleWith: nil), validLengths: [16], cvcLength: 3, prefixPattern: "^3(?:0(?:[0-5]|9)|[689])\\d*")
        case .jcb:
            return Details(icon: UIImage(named: "jcb", in: .simplifySDK, compatibleWith: nil), validLengths: [16, 17, 18, 19], cvcLength: 3, prefixPattern: "^35(?:2[89]|[3-8])\\d*")
        case .unknown:
            return Details(icon: UIImage(named: "unknown", in: .simplifySDK, compatibleWith: nil), validLengths: [12, 13, 14, 15, 16, 17, 18, 19], cvcLength: 3)
        }
    }
    
    static func detectBrand(_ number: String) -> CardBrand {
        return CardBrand.allValues.first(where: { $0.details.prefixMatches(number) }) ?? .unknown
    }
}

extension CardBrand {
    static var allValues: [CardBrand] {
        return [.visa, .mastercard, .americanExpress, .discover, .diners, .jcb, .unknown]
    }
}
