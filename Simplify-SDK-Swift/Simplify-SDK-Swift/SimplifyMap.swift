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

/// An enumeration to represent nodes in a map like structure.
///
/// - `nil`: a nil value
/// - string: a String value
/// - int: an Int value
/// - double: a Double value
/// - bool: a Boolean Value
/// - array: an array of other SimplifyMap Objects
/// - map: A Dictionary of other SimplifyMap Objects
///
/// ## Usage: ##
///
/// ```
/// var myMap = SimplifyMap()
/// myMap.path.to.something.value = "my value"
/// myMap.arrayPath[0].value = 5
/// ```
@dynamicMemberLookup public enum SimplifyMap {
    case `nil`
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([SimplifyMap])
    case map([String: SimplifyMap])
    
    /// Errors thrown when decoding a Simplify Map
    ///
    /// - invalidData: Thrown when data that can not be represented in a SimplifyMap structure is encountered
    public enum DecodingError: Error {
        case invalidData([CodingKey])
    }
    
    /// A default instance of `.nil` to use when a default is required
    public static var `default`: SimplifyMap = .nil
    
    /// defaults to nil
    public init() {
        self = .default
    }
    
        
    /// Creates a `SimplifyMap` from any object.
    /// If the object passed in is already an instance of a map.
    ///
    /// - Parameter value: Any object that can be represented by a map
    public init?(_ value: Any?) {
        guard let value = value else { return nil }
        
        switch value {
        case let b as SimplifyMap:
            self = b
        case let d as [String: SimplifyMap]:
            self = .map(d)
        case let d as [String: Any]:
            self = SimplifyMap(map: d)
        case let boxes as [SimplifyMap]:
            self = .array(boxes)
        case let array as [Any]:
            self = SimplifyMap(array: array)
        case let b as Bool:
            self = .bool(b)
        case let i as Int:
            self = .int(i)
        case let d as Double:
            self = .double(d)
        case let s as String:
            self = .string(s)
        default:
            return nil
        }
    }
        
    /// Create a `SimplifyMap.array` object from an array of objects that are convertable to `SimpifyMap`.
    ///
    /// - Parameter array: An array of objects converable to SimplifyMaps
    public init(array: [Any]) {
        self = .array(array.compactMap{ SimplifyMap($0) })
    }
    
    /// Creates an instance of `SimplifyMap.map` from the provided dictionary.
    ///
    /// - Parameter map: A dictionary of objects converable to `SimplifyMap`
    public init(map: [String: Any]) {
        self = .map(map.mapValuesCompact{ SimplifyMap($0) })
    }
    
    
}

extension SimplifyMap {
    
    /// Gets or sets the underlying value in the object
    public var value: Any? {
        get {
            switch self {
            case .nil:
                return nil
            case .string(let s):
                return s
            case .int(let i):
                return i
            case .double(let d):
                return d
            case .bool(let b):
                return b
            case .array(let boxes):
                return boxes.value
            case .map(let m):
                return m.value
            }
        }
        set {
            self = SimplifyMap(newValue) ?? .nil
        }
    }
    
    /// Gets the string value of the object
    public var stringValue: String? {
        switch self {
        case .nil:
            return nil
        case .string(let s):
            return s
        case .int(let i):
            return String(i)
        case .double(let d):
            return String(d)
        case .bool(let b):
            return String(b)
        case .array(_):
            return nil
        case .map(_):
            return nil
        }
    }
    
    /// Gets the integer value of the object
    public var intValue: Int? {
        switch self {
        case .nil:
            return nil
        case .string(let s):
            return Int(s)
        case .int(let i):
            return i
        case .double(let d):
            return Int(exactly: d)
        case .bool(let b):
            return b ? 1 : 0
        case .array(_):
            return nil
        case .map(_):
            return nil
        }
    }
    
    /// Gets the double value of the object
    public var doubleValue: Double? {
        switch self {
        case .nil:
            return nil
        case .string(let s):
            return Double(s)
        case .int(let i):
            return Double(i)
        case .double(let d):
            return d
        case .bool(let b):
            return b ? 1 : 0
        case .array(_):
            return nil
        case .map(_):
            return nil
        }
    }
    
    /// Gets the boolean value of the object
    public var boolValue: Bool? {
        switch self {
        case .nil:
            return nil
        case .string(let s):
            return Bool(s)
        case .int(let i):
            return Bool(exactly: i as NSNumber)
        case .double(let d):
            return Bool(exactly: d as NSNumber)
        case .bool(let b):
            return b
        case .array(_):
            return nil
        case .map(_):
            return nil
        }
    }
    
    /// Gets the array value of the object.  The array will contain the underlying values of all the objects in the array from the `value` property on those objects.
    public var arrayValue: [Any]? {
        switch self {
        case .nil, .string(_), .int(_), .double(_), .bool(_), .map(_):
            return nil
        case .array(let array):
            return array.value
        }
    }
    
    /// Gets the dictionary value of the object.  The dictionary will contain the underlying values of all the objects in the map from the `value` property on the values.
    public var dictionaryValue: [String: Any]? {
        switch self {
        case .nil, .string(_), .int(_), .double(_), .bool(_), .array(_):
            return nil
        case .map(let map):
            return map.value
        }
    }
}

extension SimplifyMap: Codable {
    /// `Encodable` conformance
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .nil:
            try container.encodeNil()
        case .string(let string):
            try container.encode(string)
        case .int(let integer):
            try container.encode(integer)
        case .double(let double):
            try container.encode(double)
        case .bool(let boolean):
            try container.encode(boolean)
        case .array(let array):
            try container.encode(array)
        case .map(let map):
            try container.encode(map)
        }
    }

    // `Decodable` conformance
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let obj = try? container.decode([String: SimplifyMap].self) {
            self = .map(obj)
        } else if let obj = try? container.decode([SimplifyMap].self) {
            self = .array(obj)
        } else if let obj = try? container.decode(Bool.self) {
            self = .bool(obj)
        } else if let obj = try? container.decode(Int.self) {
            self = .int(obj)
        } else if let obj = try? container.decode(Double.self) {
            self = .double(obj)
        } else if let obj = try? container.decode(String.self) {
            self = .string(obj)
        } else if container.decodeNil() {
            self = .nil
        } else {
            throw SimplifyMap.DecodingError.invalidData(container.codingPath)
        }
    }
}

extension SimplifyMap: Equatable { }

extension SimplifyMap {
    
    /// Gets the value contained at the specified key in the map.
    ///
    /// - Parameter key: The key at which to locate the desired value.
    /// - Returns: A SimplifyMap stored at the specified key or `.default` if nothing was found for the key or if the callee is not a map value.
    /// - Note: Returning a default from this function allows traversing a path to get to a value without performing optional unwraping and casting through the entire path.
    public func get(_ key: String) -> SimplifyMap {
        guard case .map(let map) = self else  { return .nil }
        return map[key] ?? .default
    }
    
    /// Sets the value for a specified key in the map
    ///
    /// - Parameters:
    ///   - object: The object to be stored.
    ///   - key: The key at which to store the object in the map.
    public mutating func set(_ object: SimplifyMap, at key: String) {
        var map:[String: SimplifyMap] = [:]
        if case .map(let existing) = self {
            map = existing
        }
        map[key] = object
        self = .map(map)
    }
    
    /// Gets the value at a given index.
    ///
    /// - Parameter index: The index of the value to get.
    /// - Returns: A SimplifyMap stored at the specified index or `.default` if the array is not long enough or if the callee is not a array value.
    public func get(_ index: Int) -> SimplifyMap {
        guard case .array(let array) = self else  { return .nil }
        return array[if: index] ?? .default
    }
    /// Sets the value for a specified index in the array
    ///
    /// - Parameters:
    ///   - object: The object to be stored.
    ///   - index: The index at which to store the object in the array.  If the index exceeds the lenght of the array, the object with be appended to the array.
    
    public mutating func set(_ object: SimplifyMap, at index: Int) {
        var array:[SimplifyMap] = []
        if case .array(let existing) = self {
            array = existing
        }
        array[if: index] = object
        self = .array(array)
    }
}

extension SimplifyMap {
    
    /// Array subscripting support.
    public subscript(index: Int) -> SimplifyMap {
        get {
            return get(index)
        }
        set(newValue) {
            set(newValue, at: index)
        }
    }

    
    /// Dictionary subscripting support.
    public subscript(key: String) -> SimplifyMap {
        get {
            return get(key)
        }
        set(newValue) {
            set(newValue, at: key)
        }
    }
    
    
    /// Dynamic member lookup support.  This allows keys to be accessed directly.
    ///
    /// For example:
    /// ```
    /// myMap.aKey.bKey[0].cKey = "testValue"
    /// ```
    /// - Parameter member: <#member description#>
    public subscript(dynamicMember member: String) -> SimplifyMap {
        get {
            return get(member)
        }
        set(newValue) {
            set(newValue, at: member)
        }
    }
}


