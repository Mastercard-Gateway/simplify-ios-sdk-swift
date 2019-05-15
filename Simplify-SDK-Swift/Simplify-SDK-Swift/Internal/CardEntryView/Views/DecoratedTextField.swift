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
class DecoratedTextField: UITextField {

    var iconContainer: UIView = UIView()
    var iconView: UIImageView = UIImageView(image: nil)
    var underlineView: UIView = UIView()

    var isValid: Bool = true
    
    var underlineColor: UIColor? {
        get { return underlineView.backgroundColor }
        set { underlineView.backgroundColor = newValue }
    }
    
    var icon: UIImage? {
        get { return iconView.image }
        set { _setIcon(newValue) }
    }
    
    var iconTintColor: UIColor {
        get { return iconView.tintColor }
        set { _setIconColor(newValue) }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

}

extension DecoratedTextField {
    func _setIcon(_ image: UIImage?) {
        iconView.image = image
        if image == nil {
            leftView = nil
        } else {
            leftView = iconContainer
        }
    }
    
    func _setIconColor(_ color: UIColor) {
        iconView.tintColor = color
        iconView.tintColorDidChange()
    }
}

extension DecoratedTextField {
    func setupView() {
        underlineColor = .gray
        iconTintColor = .darkText
        
        setupIcon()
        leftView = iconContainer
        leftViewMode = .always
        addSubview(underlineView)
        setupUnderline()
    }
    
    func setupIcon() {
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .center
        iconContainer.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        iconContainer.addSubview(iconView)
        NSLayoutConstraint.activate(iconView.superviewHuggingConstraints())
    }
    
    func setupUnderline() {
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [underlineView.heightAnchor.constraint(equalToConstant: 1)]
        constraints += underlineView.superviewHuggingConstraints(edges: [.leading, .trailing, .bottom], useMargins: false)
        NSLayoutConstraint.activate(constraints)
    }
}
