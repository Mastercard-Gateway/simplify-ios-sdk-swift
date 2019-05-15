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

struct UIViewEdges: OptionSet {
    var rawValue: Int
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static let top = UIViewEdges(rawValue: 1 << 0)
    static let bottom = UIViewEdges(rawValue: 1 << 1)
    static let leading = UIViewEdges(rawValue: 1 << 2)
    static let trailing = UIViewEdges(rawValue: 1 << 3)
    static let left = UIViewEdges(rawValue: 1 << 4)
    static let right = UIViewEdges(rawValue: 1 << 5)
    static let allLaunguageDirectional: UIViewEdges = [.top, .bottom, .leading, .trailing]
    static let allFixed: UIViewEdges = [.top, .bottom, .left, .right]
    
    
}

extension UIView {
    func superviewHuggingConstraints(insets: UIEdgeInsets = UIEdgeInsets.zero, edges: UIViewEdges = .allLaunguageDirectional, useMargins: Bool = true, relation: NSLayoutConstraint.Relation = .equal) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        if edges.contains(.top) {
            constraints.append(NSLayoutConstraint(item: self, attribute: .top, relatedBy: relation, toItem: superview, attribute: (useMargins ? .topMargin : .top), multiplier: 1, constant: insets.top))
        }
        if edges.contains(.bottom) {
            constraints.append(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: relation, toItem: superview, attribute: (useMargins ? .bottomMargin : .bottom), multiplier: 1, constant: insets.bottom))
        }
        if edges.contains(.leading) {
            constraints.append(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: relation, toItem: superview, attribute: (useMargins ? .leadingMargin : .leading), multiplier: 1, constant: insets.left))
        }
        if edges.contains(.trailing) {
            constraints.append(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: relation, toItem: superview, attribute: (useMargins ? .trailingMargin : .trailing), multiplier: 1, constant: insets.right))
        }
        if edges.contains(.left) {
            constraints.append(NSLayoutConstraint(item: self, attribute: .left, relatedBy: relation, toItem: superview, attribute: (useMargins ? .leftMargin : .left), multiplier: 1, constant: insets.left))
        }
        if edges.contains(.right) {
            constraints.append(NSLayoutConstraint(item: self, attribute: .right, relatedBy: relation, toItem: superview, attribute: (useMargins ? .rightMargin : .right), multiplier: 1, constant: insets.right))
        }
        return constraints
    }
}


