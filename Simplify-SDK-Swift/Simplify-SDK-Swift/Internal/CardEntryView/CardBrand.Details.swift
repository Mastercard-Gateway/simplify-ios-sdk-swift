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

extension CardBrand {
    struct Details {
        let icon: UIImage?
        let validLengths: [Int]
        let cvcLength: Int
        let prefixPattern: String?
        let formatter: (String) -> String
        
        init(icon: UIImage?, validLengths: [Int], cvcLength: Int, prefixPattern: String? = nil, formatter: @escaping (String) -> String = CardBrand.Details.formatterGroupFours) {
            self.icon = icon
            self.validLengths = validLengths
            self.cvcLength = cvcLength
            self.prefixPattern = prefixPattern
            self.formatter = formatter
        }
    }
}

extension CardBrand.Details {
    static func formatterGroupFours(_ input: String) -> String {
        var groups: [String] = []
        
        for i in stride(from: 0, to: input.count, by: 4) {
            let startIndex = input.index(input.startIndex, offsetBy: i, limitedBy: input.endIndex) ?? input.startIndex
            let endIndex = input.index(startIndex, offsetBy: 4, limitedBy: input.endIndex) ?? input.endIndex
            groups.append(String(input[startIndex..<endIndex]))
        }
        
        return groups.joined(separator: " ")
    }
    
    static func formatterAmex(_ input: String) -> String {
        var groups: [String] = []
        
        // first group
        var startIndex = input.index(input.startIndex, offsetBy: 0, limitedBy: input.endIndex) ?? input.startIndex
        var endIndex = input.index(startIndex, offsetBy: 4, limitedBy: input.endIndex) ?? input.endIndex
        groups.append(String(input[startIndex..<endIndex]))
        // second group
        startIndex = endIndex
        endIndex = input.index(startIndex, offsetBy: 6, limitedBy: input.endIndex) ?? input.endIndex
        if startIndex != endIndex { groups.append(String(input[startIndex..<endIndex])) }
        // third group
        startIndex = endIndex
        endIndex = input.endIndex
        if startIndex != endIndex { groups.append(String(input[startIndex..<endIndex])) }
        
        return groups.joined(separator: " ")
    }
}

extension CardBrand.Details {
    func prefixMatches(_ number: String) -> Bool {
        guard let prefixPattern = prefixPattern else { return true }
        return number.range(of: prefixPattern, options: .regularExpression) != nil
    }
}

extension CardBrand.Details {
    func validateLength(cardNumber cn: String) -> Bool {
        return validLengths.contains(cn.count)
    }
}
