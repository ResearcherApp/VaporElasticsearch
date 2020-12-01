//
//  HasParent.swift
//  
//
//  Created by Toby Stephens on 01/12/2020.
//

import Foundation

/**
 Filters documents that have fields that match any of the provided terms (not analyzed).
 
 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-nested-query.html)
 */
public struct HasParent: QueryElement {
  /// :nodoc:
  public static var typeKey = QueryElementMap.hasParent
  
  public let parentType: String
  public let query: QueryElement
  
  public init(parentType: String, query: QueryElement) {
    self.parentType = parentType
    self.query = query
  }
  
  private enum CodingKeys: String, CodingKey {
    case parentType = "parent_type"
    case query
  }
  
  /// :nodoc:
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(parentType, forKey: .parentType)
    //  Encode the query
    var queryContainer = container.nestedContainer(keyedBy: DynamicKey.self, forKey: .query)
    try queryContainer.encode(AnyQueryElement(query), forKey: DynamicKey(stringValue: type(of: query).typeKey.rawValue)!)
  }
  
  /// :nodoc:
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.parentType = try container.decode(String.self, forKey: .parentType)
    self.query = try container.decode(AnyQueryElement.self, forKey: .query).base
  }
}
