//
//  TaskResponse.swift
//  
//
//  Created by Toby Stephens on 03/02/2021.
//

import Foundation

public struct TaskResponse: Codable {
  public let task: String
  
  enum CodingKeys: String, CodingKey {
    case task
  }
}

