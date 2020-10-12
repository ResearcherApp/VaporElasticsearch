import Foundation

public struct Sort: Codable {
  let key: String
  let scoreMode: String?
  let order: SortOrder
  let nested: Sort.Nested?
  
  public init(_ key: String, scoreMode: String? = nil, _ order: SortOrder, nested: Sort.Nested? = nil) {
    self.key = key
    self.scoreMode = scoreMode
    self.order = order
    self.nested = nested
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicKey.self)
    let key = container.allKeys[0]
    self.key = key.stringValue
    
    let valuesContainer = try container.nestedContainer(keyedBy: InnerKeys.self, forKey: key)
    self.scoreMode = try valuesContainer.decodeIfPresent(String.self, forKey: .scoreMode)
    self.order = try valuesContainer.decode(SortOrder.self, forKey: .order)
    self.nested = try valuesContainer.decode(Sort.Nested?.self, forKey: .nested)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: DynamicKey.self)
    var valuesContainer = container.nestedContainer(keyedBy: InnerKeys.self, forKey: DynamicKey(stringValue: key)!)
    
    try valuesContainer.encodeIfPresent(scoreMode, forKey: .scoreMode)
    try valuesContainer.encode(order, forKey: .order)
    try valuesContainer.encodeIfPresent(nested, forKey: .nested)
  }
  
  enum InnerKeys: String, CodingKey {
    case scoreMode = "mode"
    case order
    case nested
  }
  
  
  
  public struct Nested: Codable {
    let path: String
    let filter: QueryElement?
    
    public init(path: String, filter: QueryElement? = nil) {
      self.path = path
      self.filter = filter
    }
    
    private enum CodingKeys: String, CodingKey {
      case path
      case filter
    }
    
    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(path, forKey: .path)
      //  Encode the filter
      if let filter = filter {
        var queryContainer = container.nestedContainer(keyedBy: DynamicKey.self, forKey: .filter)
        try queryContainer.encode(AnyQueryElement(filter), forKey: DynamicKey(stringValue: type(of: filter).typeKey.rawValue)!)
      }
    }
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.path = try container.decode(String.self, forKey: .path)
      self.filter = try container.decode(AnyQueryElement?.self, forKey: .filter)?.base
    }
  }
  
}



