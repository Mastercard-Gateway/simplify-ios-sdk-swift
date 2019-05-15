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

@IBDesignable
class ExpiryPickerField: DecoratedTextField {
    fileprivate enum InitMethod {
        case coder(NSCoder)
        case frame(CGRect)
    }
    
    lazy var picker: UIPickerView = {
        let p = UIPickerView()
        p.dataSource = self
        p.delegate = self
        return p
    }()
    
    var monthSelectionTitles: [String] = []
    var yearSelectionTitles: [String] = []
    
    var selectedMonthIndex: Int = 0 {
        didSet { syncPickerSelection() }
    }
    var selectedYearIndex: Int = 0{
        didSet { syncPickerSelection() }
    }
    
    fileprivate init(_ initMethod: InitMethod) {
        switch initMethod {
        case .coder(let coder): super.init(coder: coder)!
        case .frame(let frame): super.init(frame: frame)
        }
        
        self.inputView = picker
    }
    
    override convenience init(frame: CGRect) {
        self.init(.frame(frame))
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(.coder(aDecoder))
    }
    
    // prevent the selection of text
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
    
    // prevent the selection caret from showing
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    
    func syncPickerSelection() {
        picker.selectRow(selectedMonthIndex, inComponent: 0, animated: true)
        picker.selectRow(selectedYearIndex, inComponent: 1, animated: true)
    }
}

extension ExpiryPickerField: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return monthSelectionTitles.count
        case 1:
            return yearSelectionTitles.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return monthSelectionTitles[row]
        case 1:
            return yearSelectionTitles[row]
        default:
            return nil
        }
    }
}

extension ExpiryPickerField: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            selectedMonthIndex = row
        case 1:
            selectedYearIndex = row
        default:
            break
        }
        
        sendActions(for: .valueChanged)
    }
}
