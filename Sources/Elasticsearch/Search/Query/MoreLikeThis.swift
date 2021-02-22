//
//  MoreLikeThis.swift
//  
//
//  Created by Toby Stephens on 22/02/2021.
//

import Foundation

/**
 The More Like This Query finds documents that are "like" a given set of documents.
 
 [More information](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-mlt-query.html)
 */
public struct MoreLikeThis: QueryElement {
  /// :nodoc:
  public static var typeKey = QueryElementMap.moreLikeThis
  
  public struct MoreLikeThisDoc: Codable {
    public let index: String
    public let id: String
    enum CodingKeys: String, CodingKey {
      case index = "_index"
      case id = "_id"
    }
    init(index: String,
         id: String) {
      self.index = index
      self.id = id
    }
  }
  
  public let fields: [String]
  public let like: [MoreLikeThisDoc]?
  public let maxQueryTerms: Int?
  public let minTermFrequency: Int?
  public let minDocFrequency: Int?
  public let maxDocFrequency: Int?
  public let minWordLength: Int?
  public let maxWordLength: Int?

  public init(
    fields: [String],
    like: [MoreLikeThisDoc]?,
    maxQueryTerms: Int? = nil,
    minTermFrequency: Int? = nil,
    minDocFrequency: Int? = nil,
    maxDocFrequency: Int? = nil,
    minWordLength: Int? = nil,
    maxWordLength: Int? = nil
  ) {
    self.fields = fields
    self.like = like
    self.maxQueryTerms = maxQueryTerms
    self.minTermFrequency = minTermFrequency
    self.minDocFrequency = minDocFrequency
    self.maxDocFrequency = maxDocFrequency
    self.minWordLength = minWordLength
    self.maxWordLength = maxWordLength
  }
  
  enum CodingKeys: String, CodingKey {
    case fields
    case like
    case maxQueryTerms = "max_query_terms"
    case minTermFrequency = "min_term_freq"
    case minDocFrequency = "min_doc_freq"
    case maxDocFrequency = "max_doc_freq"
    case minWordLength = "min_word_length"
    case maxWordLength = "max_word_length"
  }
}

