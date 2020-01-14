import Foundation

/**
 This is the topmost container for specifying a query.
 */
public struct SearchContainer: Encodable {
    public let query: Query?
    public let sort: [Sort]?
    public let aggs: [Aggregation]?
    public let from: Int
    public let size: Int
    public let terminateAfter: Int?
  public let fields: [String]?
  public let scriptFields: [String: [String: Script]]?
  public let highlight: Highlight?

    enum CodingKeys: String, CodingKey {
        case query
        case sort
        case aggs
        case from
        case size
        case terminateAfter = "terminate_after"
      case fields = "_source"
      case scriptFields = "script_fields"
      case highlight
    }

    public init(aggs: [Aggregation]) {
        self.init(query: nil, aggs: aggs)
    }

    public init(
        _ query: Query,
        sort: [Sort]? = nil,
        aggs: [Aggregation]? = nil,
        from: Int = 0,
        size: Int = 10,
        terminateAfter: Int? = nil,
      fields: [String]? = nil,
      scriptFields: [String: [String: Script]]? = nil,
      highlight: Highlight? = nil
    ) {
      self.init(query: query, sort: sort, aggs: aggs, from: from, size: size, terminateAfter: terminateAfter, fields: fields, scriptFields: scriptFields, highlight: highlight)
    }

    private init(
        query: Query? = nil,
        sort: [Sort]? = nil,
        aggs: [Aggregation]? = nil,
        from: Int = 0,
        size: Int = 10,
        terminateAfter: Int? = nil,
        fields: [String]? = nil,
        scriptFields: [String: [String: Script]]? = nil,
        highlight: Highlight? = nil
    ) {
        self.query = query
        self.sort = sort
        self.aggs = aggs
        self.from = from
        self.size = query == nil ? 0 : size
        self.terminateAfter = terminateAfter
      self.fields = fields
      self.scriptFields = scriptFields
      self.highlight = highlight
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(from, forKey: .from)
        try container.encode(size, forKey: .size)

        try container.encodeIfPresent(query, forKey: .query)
        try container.encodeIfPresent(sort, forKey: .sort)
      try container.encodeIfPresent(fields, forKey: .fields)
      try container.encodeIfPresent(scriptFields, forKey: .scriptFields)
      try container.encodeIfPresent(highlight, forKey: .highlight)
      
        if aggs != nil && aggs!.count > 0 {
            var aggContainer = container.nestedContainer(keyedBy: DynamicKey.self, forKey: .aggs)
            for agg in aggs! {
                try aggContainer.encode(AnyAggregation(agg), forKey: DynamicKey(stringValue: agg.name)!)
            }
        }
    }
}
