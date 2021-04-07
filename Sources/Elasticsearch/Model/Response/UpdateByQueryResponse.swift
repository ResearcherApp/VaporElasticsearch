//
//  UpdateByQueryResponse.swift
//  Elasticsearch
//
//  Created by Toby Stephens on 08/06/2020.
//

import Foundation

public struct UpdateByQueryResponse: Codable {
  public let took: Int
  public let timedOut: Bool
  public let total: Int
  public let updated: Int
  public let batches: Int
  public let versionConflicts: Int
  public let noops: Int
  
  enum CodingKeys: String, CodingKey {
    case took
    case timedOut = "timed_out"
    case total
    case updated
    case batches
    case versionConflicts = "version_conflicts"
    case noops
  }
}


