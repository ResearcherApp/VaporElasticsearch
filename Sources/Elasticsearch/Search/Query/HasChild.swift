//
//  HasChild.swift
//  Elasticsearch
//
//  Created by Toby Work on 04/02/2020.
//

import Foundation

/**
 Filters documents that have fields that match any of the provided terms (not analyzed).
 
 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-nested-query.html)
 */
public struct HasChild: QueryElement {
  /// :nodoc:
  public static var typeKey = QueryElementMap.hasChild
  
  public let childType: String
  public let scoreMode: String?
  public let minChildren: Int?
  public let query: QueryElement
  public let innerHits: [String: Any]?
  
  public init(childType: String, scoreMode: String? = nil, minChildren: Int? = nil, query: QueryElement, innerHits: [String: Any]? = nil) {
    self.childType = childType
    self.scoreMode = scoreMode
    self.minChildren = minChildren
    self.query = query
    self.innerHits = innerHits
  }
  
  private enum CodingKeys: String, CodingKey {
    case childType = "type"
    case scoreMode = "score_mode"
    case minChildren = "min_children"
    case query
    case innerHits = "inner_hits"
  }
  
  /// :nodoc:
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(childType, forKey: .childType)
    try container.encodeIfPresent(scoreMode, forKey: .scoreMode)
    try container.encodeIfPresent(minChildren, forKey: .minChildren)
    //  Encode the query
    var queryContainer = container.nestedContainer(keyedBy: DynamicKey.self, forKey: .query)
    try queryContainer.encode(AnyQueryElement(query), forKey: DynamicKey(stringValue: type(of: query).typeKey.rawValue)!)
    
    if innerHits != nil && innerHits!.count > 0 {
      var keyedContainer = container.nestedContainer(keyedBy: DynamicKey.self, forKey: .innerHits)
      try encodeInnerHits(innerHits: innerHits!, in: &keyedContainer)
    }
  }
  
  private func encodeInnerHits(innerHits: [String: Any], in keyedContainer: inout KeyedEncodingContainer<DynamicKey>) throws {
    for (name, value) in innerHits {
      switch value {
      case is Int:
        try keyedContainer.encode(value as! Int, forKey: DynamicKey(stringValue: name)!)
      case is Int8:
        try keyedContainer.encode(value as! Int8, forKey: DynamicKey(stringValue: name)!)
      case is Int16:
        try keyedContainer.encode(value as! Int16, forKey: DynamicKey(stringValue: name)!)
      case is Int32:
        try keyedContainer.encode(value as! Int32, forKey: DynamicKey(stringValue: name)!)
      case is Int64:
        try keyedContainer.encode(value as! Int64, forKey: DynamicKey(stringValue: name)!)
      case is Float:
        try keyedContainer.encode(value as! Float, forKey: DynamicKey(stringValue: name)!)
      case is Double:
        try keyedContainer.encode(value as! Double, forKey: DynamicKey(stringValue: name)!)
      case is Bool:
        try keyedContainer.encode(value as! Bool, forKey: DynamicKey(stringValue: name)!)
      case is String:
        try keyedContainer.encode(value as! String, forKey: DynamicKey(stringValue: name)!)
      case is [String]:
        try keyedContainer.encode(value as! [String], forKey: DynamicKey(stringValue: name)!)
      case is [String: Any]:
        var innerKeyedContainer = keyedContainer.nestedContainer(keyedBy: DynamicKey.self, forKey: DynamicKey(stringValue: name)!)
        try encodeInnerHits(innerHits: value as! [String: Any], in: &innerKeyedContainer)
      default:
        continue
      }
    }
  }

  /// :nodoc:
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.childType = try container.decode(String.self, forKey: .childType)
    self.scoreMode = try container.decodeIfPresent(String.self, forKey: .scoreMode)
    self.minChildren = try container.decodeIfPresent(Int.self, forKey: .minChildren)
    self.query = try container.decode(AnyQueryElement.self, forKey: .query).base
    
    if container.contains(.innerHits) {
      let innerHitsContainer = try container.nestedContainer(keyedBy: DynamicKey.self, forKey: .innerHits)
      if innerHitsContainer.allKeys.count > 0 {
        var innerHits = [String: Any]()
        for key in innerHitsContainer.allKeys {
          if let value = try? innerHitsContainer.decode(Bool.self, forKey: key) {
            innerHits[key.stringValue] = value
          }
          if let value = try? innerHitsContainer.decode(Int64.self, forKey: key) {
            innerHits[key.stringValue] = value
          }
          if let value = try? innerHitsContainer.decode(Double.self, forKey: key) {
            innerHits[key.stringValue] = value
          }
          if let value = try? innerHitsContainer.decode(String.self, forKey: key) {
            innerHits[key.stringValue] = value
          }
        }
        self.innerHits = innerHits
      }
      else {
        self.innerHits = nil
      }
    }
    else {
      self.innerHits = nil
    }

  }
}
