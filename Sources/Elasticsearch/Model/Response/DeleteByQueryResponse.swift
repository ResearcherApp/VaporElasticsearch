//
//  DeleteByQueryResponse.swift
//  Elasticsearch
//
//  Created by Toby Stephens on 08/06/2020.
//

import Foundation

public struct DeleteByQueryResponse: Codable {
  public let took: Int
  public let timedOut: Bool
  public let total: Int
  public let deleted: Int
  public let batches: Int
  public let versionConflicts: Int
  public let noops: Int
  
  enum CodingKeys: String, CodingKey {
    case took
    case timedOut = "timed_out"
    case total
    case deleted
    case batches
    case versionConflicts = "version_conflicts"
    case noops
  }
}




/*
{
  "took" : 13,
  "timed_out" : false,
  "total" : 0,
  "deleted" : 0,
  "batches" : 0,
  "version_conflicts" : 0,
  "noops" : 0,
  "retries" : {
    "bulk" : 0,
    "search" : 0
  },
  "throttled_millis" : 0,
  "requests_per_second" : -1.0,
  "throttled_until_millis" : 0,
  "failures" : [ ]
}
*/
