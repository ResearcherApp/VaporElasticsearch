//
//  CountResponse.swift
//  Elasticsearch
//
//  Created by Toby Stephens on 08/06/2020.
//

import Foundation

public struct CountResponse: Codable {
  public let count: Int
  
  enum CodingKeys: String, CodingKey {
    case count
  }
}




/*
 {
 "count" : 1980383,
 "_shards" : {
 "total" : 1,
 "successful" : 1,
 "skipped" : 0,
 "failed" : 0
 }
 }
 */
