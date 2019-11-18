import HTTP

/**
 Suggest methods.
 */
extension ElasticsearchClient {
    /// Execute a suggest search in a given index
    ///
    /// - Parameters:
    ///   - index: The index to execute the query against
    ///   - query: A SearchContainer object that specifies the query to execute
    ///   - routing: Routing information
    /// - Returns: A Future SearchResponse
    public func suggest(
        index: String,
        query: SuggestContainer,
        routing: String? = nil
    ) -> Future<SuggestResponse> {
        let body: Data
        do {
            body = try self.encoder.encode(query)
        } catch {
            return worker.future(error: error)
        }
        let url = ElasticsearchClient.generateURL(path: "/\(index)/_search", routing: routing)

        return send(HTTPMethod.POST, to: url.string!, with: body).map { jsonData in
            let decoder = JSONDecoder()

            if let jsonData = jsonData {
                return try decoder.decode(SuggestResponse.self, from: jsonData)
            }

            throw ElasticsearchError(identifier: "search_failed", reason: "Could not execute suggest", source: .capture(), statusCode: 404)
        }
    }
}
