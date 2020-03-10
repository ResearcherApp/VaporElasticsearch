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
  public let query: QueryElement
  public let innerHits: [String: String]
  
  public init(childType: String, query: QueryElement, innerHits: [String: String]? = [String: String]()) {
    self.childType = childType
    self.query = query
    self.innerHits = innerHits ?? [String: String]()
  }
  
  private enum CodingKeys: String, CodingKey {
    case childType = "type"
    case query
    case innerHits = "inner_hits"
  }
  
  /// :nodoc:
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(childType, forKey: .childType)
    //  Encode the query
    var queryContainer = container.nestedContainer(keyedBy: DynamicKey.self, forKey: .query)
    try queryContainer.encode(AnyQueryElement(query), forKey: DynamicKey(stringValue: type(of: query).typeKey.rawValue)!)
    try container.encodeIfPresent(innerHits, forKey: .innerHits)
  }
  
  /// :nodoc:
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.childType = try container.decode(String.self, forKey: .childType)
    self.query = try container.decode(AnyQueryElement.self, forKey: .query).base
    self.innerHits = try container.decode([String: String].self, forKey: .innerHits)
  }
}
