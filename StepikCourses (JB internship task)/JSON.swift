//
//  JSON.swift
//  StepikCourses (JB internship task)
//
//  Created by Vadim on 10.05.17.
//  Copyright © 2017 Vadim. All rights reserved.
//

import Foundation

enum JSONError: Error {
    case IsNotConvertable(to: String)
    case UnableToParseJSON(to: String)
}

class JSON {
    
    public enum JsonType {
        case ROW_JSON(dataValue: Data)
        case DICTIONARY(dictValue: [String: Any])
        case ARRAY(arrayValue: [Any])
        case STRING(stringValue: String)
    }
    
    private let data: JsonType

    public func toString() throws -> String {
        switch data {
        case let .STRING(stringValue):
            return stringValue
        default:
            throw JSONError.IsNotConvertable(to: "string")
        }
    }
    
    private func toCollection(name: String, convert: @escaping (Any) -> JsonType)
        -> (() throws -> JSON) {
        return { () throws -> JSON in
            switch self.data {
            case let .ROW_JSON(dataValue):
                do {
                    return JSON(
                        data: convert(
                            try JSONSerialization.jsonObject(with: dataValue)
                        )
                    )
                } catch {
                    throw JSONError.UnableToParseJSON(to: name)
                }
            default:
                throw JSONError.IsNotConvertable(to: name)
            }
        }
    }
    
    public let toDictionary : (() throws -> JSON)
    
    public let toArray : (() throws -> JSON)
    
    public func
    
    init(data: JsonType) {
        self.data = data
        self.toDictionary = toCollection(
            name: "dictionary",
            convert: { (value) -> JSON.JsonType in
                return JsonType.DICTIONARY(dictValue: value as! [String : Any])
            }
        )
        self.toArray = toCollection(
            name: "array",
            convert: { (value) -> JSON.JsonType in
                return JsonType.ARRAY(arrayValue: value as! [Any])
            }
        )
    }
    
    public func getSubscript(i: Integer, JsonType) -> JSON {
        switch data {
        case .ARRAY(arrayValue):
            
        default:
            <#code#>
        }
    }

}
