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

struct LuhnValidator {
    static func validate(_ number: String) -> Bool {
        // get a reversed array of integers
        let digits = Array(number).compactMap { Int("\($0)") }.reversed()
        
        // sum the digits, doubling the odd digits
        let sum = digits.enumerated().reduce(0) { (sum, digit) -> Int in
            // only double the odd digits
            if digit.offset % 2 == 0 {
                return sum + digit.element
            }
            let value = digit.element * 2 // double the digit value
            return sum + ( value > 9 ? value - 9 : value) // if the doubled value is over 9, subtract 9
        }
        
        // the check passes if the sum is a multiple of 10
        return sum % 10 == 0
    }
}
