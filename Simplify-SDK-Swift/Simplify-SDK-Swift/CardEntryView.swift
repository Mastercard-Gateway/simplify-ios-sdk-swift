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

/// A view for collecting card information.
@IBDesignable public class CardEntryView: UIControl {
    
    /// A `SimplifyMap` card object with the information entered by the user.
    /// Any time the card is updated, `UIControlEvent.valueChanged` events are triggered.
    public var card: SimplifyMap { return _model.card }
    
    /// A boolean indicating if the card details provided pass all the validation (length, Luhn, expiration, etc.)
    public var isValid: Bool { return _model.cardValid }
    
    /// The color of the underlines on each field
    @IBInspectable public var underlineColor: UIColor = .gray { didSet { updateStyling() } }
    /// The tint color for the icons in the view
    @IBInspectable public var iconColor: UIColor = .darkGray { didSet { updateStyling() } }
    /// The color used to underline any fields that do not pass validation
    @IBInspectable public var errorColor: UIColor = .red
    /// The color used for text in the fields.
    @IBInspectable public var textColor: UIColor = .darkText { didSet { updateStyling() } }

    public init() {
        super.init(frame: .zero)
        setupView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    /// Resets all the fields to an empty state
    public func reset() {
        _model.reset()
    }
    
    // internal properties
    var _model: CardEntryViewModel = CardEntryViewModel() {
        didSet {
            render(_model)
            sendActions(for: .valueChanged)
        }
    }
    
    lazy var numberField = lazyTextField()
    
    lazy var expiryField = ExpiryPickerField()
    lazy var cvcField = lazyTextField()
    
    lazy var keyboardToolbar: UIToolbar = lazyKeyboardToolbar()
    lazy var nextButton: UIBarButtonItem = lazyKeyboardNextButton()
    lazy var doneButton: UIBarButtonItem = lazyKeyboardDoneButton()
    
    lazy var expiryCvcStack = lazyStackView(axis: .horizontal, spacing: 32, views: [expiryField, cvcField])
    
    lazy var fieldStack = lazyStackView(axis: .vertical, spacing: 0, views: [numberField, expiryCvcStack])
}

extension CardEntryView {
    
    /// Card number field placeholder text.  Use this property for localization.
    @IBInspectable public var cardNumberPlaceholderText: String? {
        get { return numberField.placeholder }
        set { numberField.placeholder = newValue }
    }
    
    /// card expiry field placeholder text.  Use this property for localization.
    @IBInspectable public var cardExpiryPlaceholderText: String? {
        get { return expiryField.placeholder }
        set { expiryField.placeholder = newValue }
    }
    
    /// CVC field placeholder text.  Use this property for localization.
    @IBInspectable public var cardCvcPlaceholderText: String? {
        get { return cvcField.placeholder }
        set { cvcField.placeholder = newValue }
    }
    
    /// The next used for the next button on the keyboard toolbar.  Use this property for localization.
    @IBInspectable public var nextButtonText: String? {
        get { return nextButton.title }
        set { nextButton.title = newValue }
    }
}

extension CardEntryView {
    /// Will attempt to make the first non-valid field the first responder.  So, if the number is valid, but the expiry is not, the expiry field will be selected.
    public override func becomeFirstResponder() -> Bool {
        sendActions(for: .editingDidBegin)
        if !_model.cardValid {
            return numberField.becomeFirstResponder()
        } else if !_model.expiryValid {
            return expiryField.becomeFirstResponder()
        } else if !_model.cvcValid {
            return cvcField.becomeFirstResponder()
        }
        
        // default
        return numberField.becomeFirstResponder()
    }
    
    public override func resignFirstResponder() -> Bool {
        numberField.resignFirstResponder()
        expiryField.resignFirstResponder()
        cvcField.resignFirstResponder()
        sendActions(for: .editingDidEnd)
        return true
    }
}
