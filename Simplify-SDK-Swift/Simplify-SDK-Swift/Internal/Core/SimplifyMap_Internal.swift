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

extension Array where Element == SimplifyMap {
    var value: [Any] {
        return compactMap { $0.value }
    }
}

extension Array {
    /// extension to subscripting for arrays that allows the return of nil if the index is invalid, appending if the index is beyond the existing array or removing at an index if you set nil
    subscript (if index: Index) -> Element? {
        get {
            return indices.contains(index) ? self[index] : nil
        }
        set {
            if indices.contains(index) {
                if let newValue = newValue {
                    self[index] = newValue
                } else {
                    self.remove(at: index)
                }
            } else if let newValue = newValue {
                self.append(newValue)
            }
        }
    }
}

extension Dictionary where Value == SimplifyMap, Key == String {
    var value: [Key: Any] {
        return mapValuesCompact { $0.value }
    }
}

extension Dictionary {
    func mapValuesCompact<T>(_ transform: (Value) throws -> T?) rethrows -> Dictionary<Key, T> {
        var result = Dictionary<Key, T>()
        for (key, value) in self {
            result[key] = try transform(value)
        }
        return result
    }
}
