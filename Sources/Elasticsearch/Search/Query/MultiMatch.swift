import Foundation

/**
 The `MultiMatch` query builds on the `MatchQuery` to allow multi-field queries.
 
 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/query-dsl-multi-match-query.html)
 */
public struct MultiMatch: QueryElement {
  /// :nodoc:
  public static var typeKey = QueryElementMap.multiMatch
  
  public let value: String
  public let fields: [String]
  public let type: Kind?
  public let analyzer: String?
  public let fuzziness: Int?
  public let tieBreaker: Decimal?
  public let `operator`: String?
  
  public init(
    value: String,
    fields: [String],
    type: Kind? = nil,
    analyzer: String? = nil,
    fuzziness: Int? = nil,
    tieBreaker: Decimal? = nil,
    `operator`: String? = nil
  ) {
    self.value = value
    self.fields = fields
    self.type = type
    self.analyzer = analyzer
    self.fuzziness = fuzziness
    self.tieBreaker = tieBreaker
    self.operator = `operator`
  }
  
  public enum Kind: String, Codable {
    case bestFields = "best_fields"
    case mostFields = "most_fields"
    case crossFields = "cross_fields"
    case phrase
    case phrasePrefix = "phrase_prefix"
  }
  
  enum CodingKeys: String, CodingKey {
    case value = "query"
    case fields
    case type
    case analyzer
    case fuzziness
    case tieBreaker = "tie_breaker"
    case `operator` = "operator"
  }
}

