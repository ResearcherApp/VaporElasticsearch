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
    routing: String? = nil,
    dateFormatter: DateFormatter? = nil
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
      if let dateFormatter = dateFormatter {
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
      }
      
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
  
  /// Execute multiple searches in a given index
  ///
  /// - Parameters:
  ///   - decodeTo: A struct or class that conforms to the Decodable protocol and can properly decode the documents stored in the index
  ///   - index: The index to execute the query against
  ///   - queries: A array of SearchContainer objects that specify the queries to execute
  ///   - routing: Routing information
  /// - Returns: A Future MultiSearchResponse
  public func multiSearch<U: Decodable>(
    decodeTo: U.Type,
    index: String,
    queries: [SearchContainer],
    scroll: ScrollKeepAlive? = nil,
    routing: String? = nil,
    dateFormatter: DateFormatter? = nil
  ) -> Future<MultiSearchResponse<U>> {
    var body = Data(capacity: 10 * 1024 * 1024)
    do {
      var firstQuery = true
      for query in queries {
        if firstQuery {
          body = try self.encoder.encode(query)
        }
        else {
          firstQuery = false
          body.append(10)
          body.append(try self.encoder.encode(query))
        }
      }
      body.append(10)
    } catch {
      return worker.future(error: error)
    }
    let url = ElasticsearchClient.generateURL(path: "/\(index)/_msearch", routing: routing, scroll: scroll)
    return send(HTTPMethod.POST, to: url.string!, with: body).map(to: MultiSearchResponse<U>.self) {jsonData in
      
      let decoder = JSONDecoder()
      if let dateFormatter = dateFormatter {
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
      }
      
      if let jsonData = jsonData {
        let decoded = try decoder.decode(MultiSearchResponse<U>.self, from: jsonData)
        
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
