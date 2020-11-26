//
//  SamplerAggregation.swift
//  
//
//  Created by Toby Stephens on 25/11/2020.
//

import Foundation

public struct ShardSize: Codable {
  let shardSize: Int
  enum CodingKeys: String, CodingKey {
    case shardSize = "shard_size"
  }
}

/**
 A special single bucket aggregation that enables aggregating nested documents.
 
 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-sampler-aggregation.html)
 */
public struct SamplerAggregation: Aggregation {
  
  /// :nodoc:
  public static var typeKey = AggregationResponseMap.nested
  
  /// :nodoc:
  public var name: String
  /// :nodoc:
  public var sampler: ShardSize
  /// :nodoc:
  public var aggs: [Aggregation]?
  
  enum CodingKeys: String, CodingKey {
    case sampler
    case aggs
  }
  
  /// Creates a [sample](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-sampler-aggregation.html) aggregation
  ///
  /// - Parameters:
  ///   - name: The aggregation name
  ///   - path: The path to the nested field
  public init(
    name: String,
    shardSize: Int,
    aggs: [Aggregation]? = nil
  ) {
    self.name = name
    self.sampler = ShardSize(shardSize: shardSize)
    self.aggs = aggs
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: DynamicKey.self)
    try container.encode(sampler, forKey: DynamicKey(stringValue: "sampler")!)
    
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
