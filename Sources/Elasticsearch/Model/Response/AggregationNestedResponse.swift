//
//  AggregationNestedResponse.swift
//  Elasticsearch
//
//  Created by Toby Stephens on 04/09/2020.
//

import Foundation

public struct AggregationNestedResponse<T: Decodable>: AggregationResponse {
  public var name: String

  public let docCount: Int
  public var aggregationBucketMap: [String: AggregationBucket<T>] = [:]
  
  enum CodingKeys: String, CodingKey {
    case docCount = "doc_count"
    case aggregationBucketMap
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = (decoder.codingPath.last?.stringValue)!
    
    self.docCount = try container.decode(Int.self, forKey: .docCount)
    
    let dynamicContainer = try decoder.container(keyedBy: DynamicKey.self)
    //let bucketsKey = DynamicKey(stringValue: "buckets")!

    for key in dynamicContainer.allKeys {
      do {
        let nestedContainer = try dynamicContainer.decode(AggregationBucket<T>.self, forKey: key)
        aggregationBucketMap[key.stringValue] = nestedContainer
      } catch {}
    }
  }
}
