//
//  Percolate.swift
//  Elasticsearch
//
//  Created by Toby Work on 15/01/2020.
//

import Foundation

public struct Percolate: QueryElement {
  /// :nodoc:
  public static var typeKey = QueryElementMap.percolate
  
  public init() {}
  
  /// :nodoc:
  public func encode(to encoder: Encoder) throws {}
  
  /// :nodoc:
  public init(from decoder: Decoder) throws {}
}
