import HTTP

/**
 Search methods.
 */
extension ElasticsearchClient {
  /// Execute a search in a given index
  ///
  /// - Parameters:
  ///   - decodeTo: A struct or class that conforms to the Decodable protocol and can properly decode the documents stored in the index
  ///   - index: The index to execute the query against
  ///   - query: A SearchContainer object that specifies the query to execute
  ///   - routing: Routing information
  /// - Returns: A Future SearchResponse
  public func search<U: Decodable>(
    decodeTo: U.Type,
    index: String,
    query: SearchContainer,
    scroll: ScrollKeepAlive? = nil,
    routing: String? = nil
  ) -> Future<SearchResponse<U>> {
    let body: Data
    do {
      body = try self.encoder.encode(query)
    } catch {
      return worker.future(error: error)
    }
    let url = ElasticsearchClient.generateURL(path: "/\(index)/_search", routing: routing, scroll: scroll)
    return send(HTTPMethod.POST, to: url.string!, with: body).map(to: SearchResponse.self) {jsonData in
      
      let decoder = JSONDecoder()
      
      // ES date format
      let isoMilisecondDateFormatter = DateFormatter()
      isoMilisecondDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
      decoder.dateDecodingStrategy = .formatted(isoMilisecondDateFormatter)
      
      if let aggregations = query.aggs {
        if aggregations.count > 0 {
          decoder.userInfo(fromAggregations: aggregations)
        }
      }
      
      if let jsonData = jsonData {
        let decoded = try decoder.decode(SearchResponse<U>.self, from: jsonData)
        
        return decoded
      }
      
      throw ElasticsearchError(identifier: "search_failed", reason: "Could not execute search", source: .capture(), statusCode: 404)
    }
  }
}
extension Data {
  var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
    guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
      let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
      let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
    
    return prettyPrintedString
  }
}
