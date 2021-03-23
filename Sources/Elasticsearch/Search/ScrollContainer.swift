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
  public let keepAlive: ScrollKeepAlive

  enum CodingKeys: String, CodingKey {
    case scrollId = "scroll_id"
    case keepAlive = "scroll"
  }
  
  public init(
    _ scrollId: String,
    keepAlive: ScrollKeepAlive = .oneMinute
  ) {
    self.scrollId = scrollId
    self.keepAlive = keepAlive
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(scrollId, forKey: .scrollId)
    try container.encode(keepAlive.rawValue, forKey: .keepAlive)
  }
}

public enum ScrollKeepAlive: String {
  case twoSeconds = "2s"
  case fiveSeconds = "5s"
  case tenSeconds = "10s"
  case thirtySeconds = "30s"
  case oneMinute = "1m"
  case fiveMinutes = "5m"
  case tenMinutes = "10m"
  case thirtyMinutes = "30m"
  case oneHour = "1h"
}
