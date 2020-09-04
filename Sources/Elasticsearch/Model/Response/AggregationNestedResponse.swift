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
  public var aggregationResponseMap: [String: AggregationResponse] = [:]
  
  enum CodingKeys: String, CodingKey {
    case docCount = "doc_count"
    case aggregationResponseMap
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = (decoder.codingPath.last?.stringValue)!
    
    self.docCount = try container.decode(Int.self, forKey: .docCount)
    
    let dynamicContainer = try decoder.container(keyedBy: DynamicKey.self)
    //let bucketsKey = DynamicKey(stringValue: "buckets")!

    for key in dynamicContainer.allKeys {
      do {
        let nestedContainer = try dynamicContainer.decode(AggregationTermsResponse<T>.self, forKey: key)
        aggregationResponseMap[key.stringValue] = nestedContainer
      } catch {}
    }
  }
}
