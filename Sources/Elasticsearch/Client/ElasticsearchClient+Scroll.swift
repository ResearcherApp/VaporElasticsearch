//
//  ElasticsearchClient+Scroll.swift
//  Async
//
//  Created by Toby Stephens on 02/06/2020.
//

import Vapor

/**
 Search methods.
 */
extension ElasticsearchClient {
  /// Execute a scroll with an existing scroll_id
  ///
  /// - Parameters:
  ///   - decodeTo: A struct or class that conforms to the Decodable protocol and can properly decode the documents stored in the index
  ///   - scrollId: The current scroll id
  ///   - keepAlive: How long to keep this context open for scrolling (default '1m')
  /// - Returns: A Future SearchResponse
  public func scroll<U: Decodable>(
    decodeTo: U.Type,
    scrollId: String,
    keepAlive: ScrollKeepAlive = .oneMinute
  ) -> Future<SearchResponse<U>> {
    let scroll = ScrollContainer(scrollId, keepAlive: keepAlive)
    let body: Data
    do {
      body = try self.encoder.encode(scroll)
    } catch {
      return worker.future(error: error)
    }
    let url = ElasticsearchClient.generateURL(path: "/_search/scroll")
    return send(HTTPMethod.POST, to: url.string!, with: body).map(to: SearchResponse.self) {jsonData in
      
      let decoder = JSONDecoder()
      if let jsonData = jsonData {
        let decoded = try decoder.decode(SearchResponse<U>.self, from: jsonData)
        
        return decoded
      }
      
      throw ElasticsearchError(identifier: "search_failed", reason: "Could not execute search", source: .capture(), statusCode: 404)
    }
  }
}
