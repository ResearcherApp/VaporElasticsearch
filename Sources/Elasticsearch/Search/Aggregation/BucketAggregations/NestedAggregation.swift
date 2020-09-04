//
//  NestedAggregation.swift
//  Elasticsearch
//
//  Created by Toby Stephens on 04/09/2020.
//

import Foundation

/**
 A special single bucket aggregation that enables aggregating nested documents.
 
 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-nested-aggregation.html)
 */
public struct NestedAggregation: Aggregation {
  
  /// :nodoc:
  public static var typeKey = AggregationResponseMap.nested
  
  /// :nodoc:
  public var name: String
  /// :nodoc:
  public let path: String
  /// :nodoc:
  public var aggs: [Aggregation]?
  
  enum CodingKeys: String, CodingKey {
    case path
    case aggs
  }
  
  /// Creates a [terms](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-terms-aggregation.html) aggregation
  ///
  /// - Parameters:
  ///   - name: The aggregation name
  ///   - path: The path to the nested field
  public init(
    name: String,
    path: String,
    aggs: [Aggregation]? = nil
  ) {
    self.name = name
    self.path = path
    self.aggs = aggs
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: DynamicKey.self)
    var valuesContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: DynamicKey(stringValue: type(of: self).typeKey.rawValue)!)
    try valuesContainer.encode(path, forKey: .path)
    if aggs != nil && aggs!.count > 0 {
      var aggContainer = container.nestedContainer(keyedBy: DynamicKey.self, forKey: DynamicKey(stringValue: "aggs")!)
      for agg in aggs! {
        try aggContainer.encode(AnyAggregation(agg), forKey: DynamicKey(stringValue: agg.name)!)
      }
    }
  }
  
  public enum CollectMode: String, Encodable {
    case breadthFirst = "breadth_first"
    case depthFirst = "depth_first"
  }
  
  public enum ExecutionHint: String, Encodable {
    case map
    case globalOrdinals = "global_ordinals"
  }
}
