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

import XCTest
@testable import Simplify

class SimplifyMapTests: XCTestCase {
    
    var testSubject: SimplifyMap!
    
    
    var allSimpleValues:[String : Any]!
    var complexValues:[String : Any]!
    
    override func setUp() {
        testSubject = SimplifyMap()
        allSimpleValues =  ["string" : "A", "int" : 1, "double" : 1.25, "true": true, "false" : false, "nil" : SimplifyMap.nil]
        complexValues =  ["map" : allSimpleValues, "array" : [allSimpleValues, allSimpleValues]]
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDefaultInit() {
        XCTAssertEqual(testSubject, .nil)
    }
    
    func testInitNil() {
        XCTAssertNil(SimplifyMap(nil))
    }
    
    func testInitString() {
        let constructed = SimplifyMap("test")
        XCTAssertEqual(constructed, .string("test"))
    }
    
    func testInitDouble() {
        let constructed = SimplifyMap(3.14159)
        XCTAssertEqual(constructed, .double(3.14159))
    }
    
    func testInitInt() {
        let constructed = SimplifyMap(3)
        XCTAssertEqual(constructed, .int(3))
    }
    
    func testInitBool() {
        let constructedTrue = SimplifyMap(true)
        let constructedFalse = SimplifyMap(false)
        XCTAssertEqual(constructedTrue, .bool(true))
        XCTAssertEqual(constructedFalse, .bool(false))
    }
    
    func testInitArrayValues() {
        testSubject = SimplifyMap(["hi", 1, 3.14159, false])!
        XCTAssertEqual(testSubject, .array([.string("hi"), .int(1), .double(3.14159), .bool(false)]))
    }
    
    func testInitArray() {
        let values: [SimplifyMap] = [.string("hi"), .int(1), .double(3.14159), .bool(false)]
        testSubject = SimplifyMap(values)!
        XCTAssertEqual(testSubject, .array([.string("hi"), .int(1), .double(3.14159), .bool(false)]))
    }
    
    func testInitMapValues() {
        testSubject = SimplifyMap(["string":"hi", "int":1, "double":3.14159, "bool":false])!
        XCTAssertEqual(testSubject, .map(["string":.string("hi"), "int":.int(1), "double":.double(3.14159), "bool":.bool(false)]))
    }
    
    func testInitMap() {
        let map: [String: SimplifyMap] = ["string":.string("hi"), "int":.int(1), "double":.double(3.14159), "bool":.bool(false)]
        testSubject = SimplifyMap(map)!
        XCTAssertEqual(testSubject, .map(["string":.string("hi"), "int":.int(1), "double":.double(3.14159), "bool":.bool(false)]))
    }
    
    func testInitFail() {
        XCTAssertNil(SimplifyMap(NSDate()))
    }
    
    func testInitExistingMap() {
        let wrapped = SimplifyMap(SimplifyMap.string("test"))
        XCTAssertEqual(wrapped, .string("test"))
    }
    
    func testNilValueRepresentations() {
        testSubject = .nil
        XCTAssertNil(testSubject.value)
        XCTAssertNil(testSubject.stringValue)
        XCTAssertNil(testSubject.intValue)
        XCTAssertNil(testSubject.doubleValue)
        XCTAssertNil(testSubject.boolValue)
        XCTAssertNil(testSubject.arrayValue)
        XCTAssertNil(testSubject.dictionaryValue)
    }
    
    func testStringValueRepresentations() {
        testSubject = .string("test")
        XCTAssertEqual(testSubject.value as? String, "test")
        XCTAssertEqual(testSubject.stringValue, "test")
        XCTAssertNil(testSubject.intValue )
        XCTAssertNil(testSubject.doubleValue)
        XCTAssertNil(testSubject.boolValue)
        XCTAssertNil(testSubject.arrayValue)
        XCTAssertNil(testSubject.dictionaryValue)
    }
    
    func testIntValueRepresentations() {
        testSubject = .int(1)
        XCTAssertEqual(testSubject.value as? Int, 1)
        XCTAssertEqual(testSubject.stringValue, "1")
        XCTAssertEqual(testSubject.intValue, 1)
        XCTAssertEqual(testSubject.doubleValue, 1.0)
        XCTAssertEqual(testSubject.boolValue, true)
        XCTAssertNil(testSubject.arrayValue)
        XCTAssertNil(testSubject.dictionaryValue)
    }
    
    func testDoubleValueRepresentations() {
        testSubject = .double(1.5)
        XCTAssertEqual(testSubject.value as? Double, 1.5)
        XCTAssertEqual(testSubject.stringValue, "1.5")
        XCTAssertNil(testSubject.intValue)
        XCTAssertEqual(testSubject.doubleValue, 1.5)
        XCTAssertNil(testSubject.boolValue)
        XCTAssertNil(testSubject.arrayValue)
        XCTAssertNil(testSubject.dictionaryValue)
    }
    
    func testBoolTrueValueRepresentations() {
        testSubject = .bool(true)
        XCTAssertEqual(testSubject.value as? Bool, true)
        XCTAssertEqual(testSubject.stringValue, "true")
        XCTAssertEqual(testSubject.intValue, 1)
        XCTAssertEqual(testSubject.doubleValue, 1.0)
        XCTAssertEqual(testSubject.boolValue, true)
        XCTAssertNil(testSubject.arrayValue)
        XCTAssertNil(testSubject.dictionaryValue)
    }
    
    func testBoolFalseValueRepresentations() {
        testSubject = .bool(false)
        XCTAssertEqual(testSubject.value as? Bool, false)
        XCTAssertEqual(testSubject.stringValue, "false")
        XCTAssertEqual(testSubject.intValue, 0)
        XCTAssertEqual(testSubject.doubleValue, 0.0)
        XCTAssertEqual(testSubject.boolValue, false)
        XCTAssertNil(testSubject.arrayValue)
        XCTAssertNil(testSubject.dictionaryValue)
    }
    
    func testArrayValueRepresentations() {
        testSubject = .array([.string("hi"), .int(1), .double(3.14159), .bool(false)])
        
        XCTAssertNotNil(testSubject.value as? [Any])
        XCTAssertNil(testSubject.stringValue)
        XCTAssertNil(testSubject.intValue)
        XCTAssertNil(testSubject.doubleValue)
        XCTAssertNil(testSubject.boolValue)
        let arrayValue = testSubject.arrayValue
        XCTAssertNotNil(arrayValue)
        XCTAssertEqual(arrayValue?[0] as? String, "hi")
        XCTAssertEqual(arrayValue?[1] as? Int, 1)
        XCTAssertEqual(arrayValue?[2] as? Double, 3.14159)
        XCTAssertEqual(arrayValue?[3] as? Bool, false)
        XCTAssertNil(testSubject.dictionaryValue)
    }
    
    func testDictionaryValueRepresentations() {
        testSubject = .map(["string":.string("hi"), "int":.int(1), "double":.double(3.14159), "bool":.bool(false)])
        
        XCTAssertNotNil(testSubject.value as? [String:Any])
        XCTAssertNil(testSubject.stringValue)
        XCTAssertNil(testSubject.intValue)
        XCTAssertNil(testSubject.doubleValue)
        XCTAssertNil(testSubject.boolValue)
        XCTAssertNil(testSubject.arrayValue)
        let dictionaryValue = testSubject.dictionaryValue
        XCTAssertNotNil(dictionaryValue)
        XCTAssertEqual(dictionaryValue?["string"] as? String, "hi")
        XCTAssertEqual(dictionaryValue?["int"] as? Int, 1)
        XCTAssertEqual(dictionaryValue?["double"] as? Double, 3.14159)
        XCTAssertEqual(dictionaryValue?["bool"] as? Bool, false)
    }
    
    func testMappingIntValuesToBools() {
        testSubject = .int(0)
        XCTAssertEqual(testSubject.boolValue, false)
        testSubject = .int(1)
        XCTAssertEqual(testSubject.boolValue, true)
        testSubject = .int(2)
        XCTAssertEqual(testSubject.boolValue, nil)
        testSubject = .int(-1)
        XCTAssertEqual(testSubject.boolValue, nil)
    }
    
    func testMappingDoubleValuesToBools() {
        testSubject = .double(0.0)
        XCTAssertEqual(testSubject.boolValue, false)
        testSubject = .double(1.0)
        XCTAssertEqual(testSubject.boolValue, true)
        testSubject = .double(2.0)
        XCTAssertEqual(testSubject.boolValue, nil)
        testSubject = .double(-1.0)
        XCTAssertEqual(testSubject.boolValue, nil)
    }
    
    func testCodableSupport() {
        testSubject = SimplifyMap(complexValues)
        // mocking Encoder and Decoder is very time consuming so we are simply going to encode and then decode a payload and test the result for equality with the initial map
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let encoded = try encoder.encode(testSubject)
            let decoded = try decoder.decode(SimplifyMap.self, from: encoded)
            XCTAssertEqual(decoded, testSubject)
        } catch {
            XCTFail("Unexpected exception thrown - \(error.localizedDescription)")
        }
    }
    
    func testArraySubscriptingAccess() {
        testSubject = .array([.string("hi"), .int(1), .double(3.14159), .bool(false)])
        
        XCTAssertEqual(testSubject[0], .string("hi"))
        XCTAssertEqual(testSubject[1], .int(1))
        XCTAssertEqual(testSubject[2], .double(3.14159))
        XCTAssertEqual(testSubject[3], .bool(false))
        XCTAssertEqual(testSubject[4], .nil)
    }
    
    func testArraySubscriptingSetting() {
        testSubject[1] = .string("zero")
        XCTAssertEqual(testSubject, .array([.string("zero")]))
        testSubject[1] = .string("one")
        XCTAssertEqual(testSubject, .array([.string("zero"), .string("one")]))
    }
    
    func testArraySubscriptingAccessNonArray() {
        XCTAssertEqual(testSubject[0], .nil)
    }
    
    func testMapSubscriptingAccess() {
        testSubject = .map(["string":.string("hi"), "int":.int(1), "double":.double(3.14159), "bool":.bool(false)])
        
        XCTAssertEqual(testSubject["string"], .string("hi"))
        XCTAssertEqual(testSubject["int"], .int(1))
        XCTAssertEqual(testSubject["double"], .double(3.14159))
        XCTAssertEqual(testSubject["bool"], .bool(false))
        XCTAssertEqual(testSubject["notSet"], .nil)
    }
    
    func testMapSubscriptingSetting() {
        testSubject["a"] = .string("A")
        XCTAssertEqual(testSubject, .map(["a" : .string("A")]))
        testSubject["b"] = .string("B")
        XCTAssertEqual(testSubject, .map(["a" : .string("A"), "b" : .string("B")]))
    }
    
    func testMapSubscriptingAccessNonMap() {
        XCTAssertEqual(testSubject["notAMap"], .nil)
    }
    
    func testMapDynamicMemberAccess() {
        testSubject = .map(["string":.string("hi"), "int":.int(1), "double":.double(3.14159), "bool":.bool(false)])
        
        XCTAssertEqual(testSubject.string, .string("hi"))
        XCTAssertEqual(testSubject.int, .int(1))
        XCTAssertEqual(testSubject.double, .double(3.14159))
        XCTAssertEqual(testSubject.bool, .bool(false))
        XCTAssertEqual(testSubject.notSet, .nil)
    }
    
    func testMapDynamicMemberSetting() {
        testSubject.a = .string("A")
        XCTAssertEqual(testSubject, .map(["a" : .string("A")]))
        testSubject.b = .string("B")
        XCTAssertEqual(testSubject, .map(["a" : .string("A"), "b" : .string("B")]))
    }
    
    func testMapDynamicMemberAccessNonMap() {
        XCTAssertEqual(testSubject.notAMap, .nil)
    }
    
    func testValueSettingConvertableValue() {
        testSubject.value = "string"
        XCTAssertEqual(testSubject, .string("string"))
    }
    
    func testValueSettingNonConvertableValue() {
        testSubject.value = Date()
        XCTAssertEqual(testSubject, .nil)
    }
    
    func testSettingNestedValues() {
        testSubject.ra.inb[0].w = .string("Gold")
        XCTAssertEqual(testSubject, .map(["ra" : .map(["inb" : .array([.map(["w" : .string("Gold")])])])]))
    }
    
    func testGettingNestedValues() {
        testSubject = .map(["ra" : .map(["inb" : .array([.map(["w" : .string("Gold")])])])])
        XCTAssertEqual(testSubject.ra.inb[0].w, .string("Gold"))
    }
}


