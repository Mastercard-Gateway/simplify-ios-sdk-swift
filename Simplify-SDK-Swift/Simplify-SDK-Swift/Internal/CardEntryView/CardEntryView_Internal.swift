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

// MARK: - Internal functions
extension CardEntryView {
    func setupView() {
        addSubview(fieldStack)
        
        expiryCvcStack.distribution = .fillEqually
        fieldStack.distribution = .fillEqually
        
        numberField.keyboardType = .numberPad
        numberField.returnKeyType = .next
        numberField.clearButtonMode = .always
        cvcField.keyboardType = .numberPad
        cvcField.returnKeyType = .done
        cvcField.clearButtonMode = .always
        
        numberField.inputAccessoryView = keyboardToolbar
        expiryField.inputAccessoryView = keyboardToolbar
        cvcField.inputAccessoryView = keyboardToolbar
        
        var constraints = fieldStack.superviewHuggingConstraints()
        constraints.append(numberField.heightAnchor.constraint(equalToConstant: 60))
        NSLayoutConstraint.activate(constraints)
        setupActions()
        setupStaticValues()
        
        // render the initial state
        render(_model)
    }
    
    func setupActions() {
        numberField.addTarget(self, action: #selector(numberChanged(_:)), for: .editingChanged)
        cvcField.addTarget(self, action: #selector(cvcChanged(_:)), for: .editingChanged)
        expiryField.addTarget(self, action: #selector(expiryEditingBegan(_:)), for: .editingDidBegin)
        expiryField.addTarget(self, action: #selector(expiryChanged(_:)), for: .valueChanged)
        
        numberField.addTarget(self, action: #selector(numberEditingBegan(_:)), for: .editingDidBegin)
        expiryField.addTarget(self, action: #selector(expiryEditingBegan(_:)), for: .editingDidBegin)
        cvcField.addTarget(self, action: #selector(cvcEditingBegan(_:)), for: .editingDidBegin)
        
        numberField.addTarget(self, action: #selector(numberEditingEnded), for: .editingDidEnd)
        expiryField.addTarget(self, action: #selector(expiryEditingEnded), for: .editingDidEnd)
        cvcField.addTarget(self, action: #selector(cvcEditingEnded), for: .editingDidEnd)

    }
    
    func setupStaticValues() {
        // These values are not localized, it is on the integrator to localize the placholders using the properties provided
        numberField.placeholder = "Card Number"
        expiryField.placeholder = "Expiry"
        cvcField.placeholder = "CVC"
        expiryField.icon = UIImage(named: "expiry", in: .simplifySDK, compatibleWith: nil)
        cvcField.icon = UIImage(named: "cvc", in: .simplifySDK, compatibleWith: nil)
    }
    
    func render(_ viewModel: CardEntryViewModel) {
        numberField.icon = viewModel.cardBrandIcon
        numberField.text = viewModel.formattedCardNumber
        
        expiryField.monthSelectionTitles = viewModel.expiryMonthTitles
        expiryField.yearSelectionTitles = viewModel.expiryYearTitles
        expiryField.selectedMonthIndex = viewModel.selectedExpiryMonthIndex
        expiryField.selectedYearIndex = viewModel.selectedExpiryYearIndex
        
        expiryField.text = viewModel.expiryFormatted
        
        cvcField.text = viewModel.cvc
    }
    
    
}

extension CardEntryView {
    @IBAction func numberChanged(_ sender: Any) {
        _model.formattedCardNumber = numberField.text
    }
    
    @IBAction func cvcChanged(_ sender: Any) {
        _model.cvc = cvcField.text
    }
    
    @IBAction func expiryChanged(_ sender: Any) {
        _model.updateExpirySelection(month: expiryField.selectedMonthIndex, year: expiryField.selectedYearIndex)
    }
    
    @IBAction func numberEditingBegan(_ sender: Any) {
        numberField.underlineColor = tintColor
        nextButton.target = self
        nextButton.action = #selector(selectExpiryAction(_:))
        keyboardToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), nextButton]
    }
    
    @IBAction func expiryEditingBegan(_ sender: Any) {
        _model.initiateExpiryEditing()
        expiryField.underlineColor = tintColor
        nextButton.target = self
        nextButton.action = #selector(selectCvcAction(_:))
        keyboardToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), nextButton]
    }
    
    @IBAction func cvcEditingBegan(_ sender: Any) {
        cvcField.underlineColor = tintColor
        keyboardToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton]
    }
    
    @IBAction func numberEditingEnded() {
        numberField.underlineColor = _model.numberValid ? underlineColor : errorColor
    }
    
    @IBAction func expiryEditingEnded() {
        expiryField.underlineColor = _model.expiryValid ? underlineColor : errorColor
    }
    
    @IBAction func cvcEditingEnded() {
        cvcField.underlineColor = _model.cvcValid ? underlineColor : errorColor
    }
}

extension CardEntryView {
    func updateStyling() {
        style(numberField)
        style(expiryField)
        style(cvcField)
    }
    
    func style(_ field: DecoratedTextField) {
        field.textColor = textColor
        field.iconTintColor = iconColor
        field.underlineColor = underlineColor
    }
}


// MARK: - Lazy Constructor Functions
extension CardEntryView {
    func lazyStackView(axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment = .fill, spacing: CGFloat = 8, views: [UIView] = []) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = axis
        stack.alignment = alignment
        stack.spacing = spacing
        return stack
    }
    
    func lazyTextField(alignment: NSTextAlignment = .natural) -> DecoratedTextField {
        let field = DecoratedTextField()
        field.textAlignment = alignment
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }
    
    func lazyKeyboardToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.tintColor = tintColor
        toolbar.sizeToFit()
        return toolbar
    }
    
    func lazyKeyboardDoneButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(_:)))
        return button
    }
    
    func lazyKeyboardNextButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(title: "Next", style: .done, target: self, action: nil)
        return button
    }
}

extension CardEntryView {
    @objc func doneAction(_ sender: Any) {
        _ = resignFirstResponder()
    }
    
    @objc func selectExpiryAction(_ sender: Any) {
        _ = expiryField.becomeFirstResponder()
    }
    
    @objc func selectCvcAction(_ sender: Any) {
        _ = cvcField.becomeFirstResponder()
    }
}

extension CardEntryView {
    override public func prepareForInterfaceBuilder() {
        numberEditingBegan(self)
    }
    
    public override func tintColorDidChange() {
        keyboardToolbar.tintColor = tintColor
        keyboardToolbar.tintColorDidChange()
    }
}

extension CardEntryView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == numberField {
            expiryField.becomeFirstResponder()
        } else if textField == expiryField {
            cvcField.becomeFirstResponder()
        } else if textField == cvcField {
            cvcField.resignFirstResponder()
        }
        return true
    }
}
