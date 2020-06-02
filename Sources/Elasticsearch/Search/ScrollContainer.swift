//
//  ScrollContainer.swift
//  Elasticsearch
//
//  Created by Toby Stephens on 02/06/2020.
//

import Foundation

/**
 This is the topmost container for specifying a scroll request.
 */
public struct ScrollContainer: Encodable {
  public let scrollId: String
  public let keepAlive: String

  enum CodingKeys: String, CodingKey {
    case scrollId = "scroll_id"
    case keepAlive = "scroll"
  }
  
  public init(
    _ scrollId: String,
    keepAlive: String = "1m"
  ) {
    self.scrollId = scrollId
    self.keepAlive = keepAlive
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(scrollId, forKey: .scrollId)
    try container.encode(keepAlive, forKey: .keepAlive)
  }
}
