//
//  MultiSearchResponse.swift
//  
//
//  Created by Toby Stephens on 09/10/2020.
//

import Foundation

public struct MultiSearchResponse<T: Decodable>: Decodable {
  
  public let responses: [SearchResponse<T>]
  
  enum CodingKeys: String, CodingKey {
    case responses
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.responses = try container.decode([SearchResponse<T>].self, forKey: .responses)
  }
}


