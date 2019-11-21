//
//  Highlight.swift
//  Async
//
//  Created by Toby Work on 20/11/2019.
//

import Foundation


public struct Highlight: Codable {
  let fields: [String]
  
  public init(_ fields: [String]) {
    self.fields = fields
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicKey.self)
    let fieldsContainer = try container.nestedContainer(keyedBy: DynamicKey.self, forKey: DynamicKey(stringValue: "fields")!)
    self.fields = fieldsContainer.allKeys.compactMap { $0.stringValue }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: DynamicKey.self)
    var fieldsContainer = container.nestedContainer(keyedBy: DynamicKey.self, forKey: DynamicKey(stringValue: "fields")!)
    for field in fields {
      try fieldsContainer.encode([String:String](), forKey: DynamicKey(stringValue: field)!)
    }
  }
}
