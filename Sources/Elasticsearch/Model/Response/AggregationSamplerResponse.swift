//
//  AggregationSamplerResponse.swift
//  
//
//  Created by Toby Stephens on 25/11/2020.
//

import Foundation

public struct AggregationSamplerResponse<T: Decodable>: AggregationResponse {
  public var name: String
  
  public let docCount: Int
  public let score: SamplerScore?
  public var aggregationResponseMap: [String: AggregationResponse] = [:]
  
  enum CodingKeys: String, CodingKey {
    case docCount = "doc_count"
    case score
    case aggregationResponseMap
  }
  
  public struct SamplerScore: Decodable {
    var value: Double
    enum CodingKeys: String, CodingKey {
      case value
    }
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = (decoder.codingPath.last?.stringValue)!
    
    self.docCount = try container.decode(Int.self, forKey: .docCount)
    self.score = try container.decode(SamplerScore?.self, forKey: .score)
    
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
