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

struct CardEntryViewModel {
    // MARK: Inputs
    var number: String?
    var expiryYear: Int?
    var expiryMonth: Int?
    var cvc: String?
    
    var currentYear: Int
    var currentMonth: Int
    
    var numberOfExpiryYears = 20
    var expiryFormatter = DateFormatter()
    
    var calendar: Calendar = .current
    
    init(currentYear: Int, currentMonth: Int) {
        self.currentYear = currentYear
        self.currentMonth = currentMonth
        expiryFormatter.dateFormat = "MM/YY"
    }
    
    init(current date: Date = Date(), calendar: Calendar = .current) {
        let year = calendar.component(.year, from: date) % 100 // Simplify expects 2 digit years for card expiration
        let month = calendar.component(.month, from: date)
        self.init(currentYear: year, currentMonth: month)
        self.calendar = calendar
    }
    
}

extension CardEntryViewModel {
    // MARK: Outputs
    var card: SimplifyMap {
        var card = SimplifyMap()
        card.number.value = number
        card.expYear.value = expiryYear
        card.expMonth.value = expiryMonth
        card.cvc.value = cvc
        return card
    }
    
    var cardValid: Bool {
        return numberValid && expiryValid && cvcValid
    }
    
    var numberValid: Bool {
        guard let number = number else { return false }
        return brand.details.validateLength(cardNumber: number) && LuhnValidator.validate(number)
    }
    
    var expiryValid: Bool {
        guard let expiryMonth = expiryMonth, let expiryYear = expiryYear else { return false }
        return expiryMonth >= currentMonth || expiryYear > currentYear
    }
    
    var cvcValid: Bool {
        guard let cvc = cvc else { return false }
        return brand.details.cvcLength == cvc.count
    }
    
    var cardBrandIcon: UIImage? {
        return brand.details.icon
    }
    
    var formattedCardNumber: String? {
        get {
            guard let number = number else { return nil }
            return brand.details.formatter(number)
        }
        set {
            if let newValue = newValue {
                number = normalizeCard(newValue)
            } else {
                number = newValue
            }
        }
    }
    
    var expiryFormatted: String? {
        guard let date = expiryDate else {
            return nil
        }
        return expiryFormatter.string(from: date)
    }
    
    // MARK: Expiration Picker values
    var expiryMonthValues: [Int] { return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] }
    var expiryYearValues: [Int] { return Array((currentYear ..< (currentYear + numberOfExpiryYears))) }
    var expiryMonthTitles: [String] {
        return expiryMonthValues.enumerated().map { "\(expiryFormatter.shortMonthSymbols[$0.offset])(\($0.element))" }
    }
    
    var expiryYearTitles: [String] {
        return expiryYearValues.map { "\($0 + 2000)" }
    }
    
    var selectedExpiryMonthIndex: Int {
        get {
            return expiryMonthValues.firstIndex(of: expiryMonth ?? currentMonth) ?? 0
        }
        set {
            expiryMonth = expiryMonthValues[newValue]
        }
    }
    
    var selectedExpiryYearIndex: Int {
        get {
            return expiryYearValues.firstIndex(of: expiryYear ?? currentYear) ?? 0
        }
        set {
            expiryYear = expiryYearValues[newValue]
        }
    }
    
    mutating func updateExpirySelection(month: Int, year: Int) {
        selectedExpiryMonthIndex = month
        selectedExpiryYearIndex = year
    }
    
    mutating func initiateExpiryEditing() {
        if expiryMonth == nil {
            expiryMonth = currentMonth
        }
        if expiryYear == nil {
            expiryYear = currentYear
        }
    }
    
    mutating func reset() {
        number = nil
        expiryMonth = nil
        expiryYear = nil
        cvc = nil
    }
}

extension CardEntryViewModel {
    fileprivate var brand: CardBrand {
        guard let number = number else { return .unknown }
        return CardBrand.detectBrand(number)
    }
    
    fileprivate var expiryDate: Date? {
        guard let month = expiryMonth, let year = expiryYear else { return nil }
        var components = DateComponents()
        components.year = year
        components.month = month
        return calendar.date(from: components)
    }
    
    fileprivate func normalizeCard(_ number: String) -> String {
        return number.replacingOccurrences(of: "[^\\d]+", with: "", options: .regularExpression) // just the digits
    }
}
