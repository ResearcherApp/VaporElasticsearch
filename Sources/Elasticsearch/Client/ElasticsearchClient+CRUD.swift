import HTTP

/**
 CRUD methods.
 */
extension ElasticsearchClient {
    /// Gets a document from Elasticsearch
    ///
    /// - Parameters:
    ///   - resultType: The model to decode the document into
    ///   - index: The index to get the document from
    ///   - id: The document id
    ///   - routing: The routing information
    ///   - version: The version information
    ///   - storedFields: Only return the stored fields
    ///   - realtime: Fetch realtime results
    /// - Returns: A Future DocResponse
    public func get<T: Decodable>(
        decodeTo resultType: T.Type,
        index: String,
        id: String,
        routing: String? = nil,
        version: Int? = nil,
        storedFields: [String]? = nil,
      realtime: Bool? = nil,
      dateFormatter: DateFormatter? = nil
    ) -> Future<DocResponse<T>?> {
        let url = ElasticsearchClient.generateURL(path: "/\(index)/_doc/\(id)", routing: routing, version: version, storedFields: storedFields, realtime: realtime)
        return send(HTTPMethod.GET, to: url.string!).map(to: DocResponse?.self) {jsonData in
            if let jsonData = jsonData {
              
              if let dateFormatter = dateFormatter {
                self.decoder.dateDecodingStrategy = .formatted(dateFormatter)
              }

                return try self.decoder.decode(DocResponse<T>.self, from: jsonData)
            }
            return nil
        }
    }

    /// Index (save) a document
    ///
    /// - Parameters:
    ///   - doc: The document to index (save)
    ///   - index: The index to put the document into
    ///   - id: The id for the document. If not provided, an id will be automatically generated.
    ///   - routing: Routing information for what node the document should be saved on
    ///   - version: Version information
    ///   - forceCreate: Force creation
    /// - Returns: A Future IndexResponse
    public func index<T: Encodable>(
        doc: T,
        index: String,
        id: String? = nil,
        routing: String? = nil,
        version: Int? = nil,
        forceCreate: Bool? = nil,
      dateFormatter: DateFormatter? = nil
    ) -> Future<IndexResponse> {
        let url = ElasticsearchClient.generateURL(path: "/\(index)/_doc/\(id ?? "")", routing: routing, version: version, forceCreate: forceCreate)
        let method = id != nil ? HTTPMethod.PUT : HTTPMethod.POST
      
      // Set any custom date formatter
      if let dateFormatter = dateFormatter {
        self.encoder.dateEncodingStrategy = .formatted(dateFormatter)
      }
      
        let body: Data
        do {
            body = try self.encoder.encode(doc)
        } catch {
            return worker.future(error: error)
        }
        return send(method, to: url.string!, with:body).map(to: IndexResponse.self) {jsonData in
            if let jsonData = jsonData {
                return try self.decoder.decode(IndexResponse.self, from: jsonData)
            }
            throw ElasticsearchError(identifier: "indexing_failed", reason: "Cannot index document", source: .capture(), statusCode: 404)
        }
    }

    /// Update a document stored at the given id without sending the
    /// whole document in the request ("partial update").
    ///
    /// Send either a partial document (`doc` ) which will be deeply merged into an existing document,
    /// or a `script`, which will update the document content
    ///
    /// Script will take priority over a doc if both are set.
    ///
    /// - Parameters:
    ///   - doc: The document to update
    ///   - index: The document index
    ///   - id: The document id
    ///   - routing: Routing information
    ///   - version: Version information
    /// - Returns: A Future IndexResponse
    ///
    public func update<T: Encodable>(
        doc: T,
      prewrapped: Bool = false,
        index: String,
        id: String,
        routing: String? = nil,
      version: Int? = nil,
      dateFormatter: DateFormatter? = nil
    ) -> Future<IndexResponse>{
        let url = ElasticsearchClient.generateURL(path: "/\(index)/_doc/\(id)/_update", routing: routing, version: version)
        let body: Data
      
      // Set any custom date formatter
      if let dateFormatter = dateFormatter {
        self.encoder.dateEncodingStrategy = .formatted(dateFormatter)
      }

        do {
          
          if prewrapped {
            body = try self.encoder.encode(doc)
          }
          else {
            let wrappedDoc: [String: T] = [ "doc" : doc ]
            body = try self.encoder.encode(wrappedDoc)
          }

        } catch {
            return worker.future(error: error)
        }
        return update(url: url, body: body)
    }

    /// - Parameters:
    ///   - script: The Script to execute
    ///   - index: The document index
    ///   - id: The document id
    ///   - routing: Routing information
    ///   - version: Version information
    /// - Returns: A Future IndexResponse
    ///
    public func update(
        script: Script,
        index: String,
        id: String,
        routing: String? = nil,
      version: Int? = nil,
      dateFormatter: DateFormatter? = nil
    ) -> Future<IndexResponse>{
        let url = ElasticsearchClient.generateURL(path: "/\(index)/_doc/\(id)/_update", routing: routing, version: version)
        let body: Data
      
      // Set any custom date formatter
      if let dateFormatter = dateFormatter {
        self.encoder.dateEncodingStrategy = .formatted(dateFormatter)
      }

        do {
            let wrappedScript: [String: Script] = [ "script" : script ]
            body = try self.encoder.encode(wrappedScript)
        } catch {
            return worker.future(error: error)
        }
        return update(url: url, body: body)
    }

    fileprivate func update(
        url: URLComponents,
        body: Data
    ) -> Future<IndexResponse>{
        return send(HTTPMethod.POST, to: url.string!, with:body).map(to: IndexResponse.self) {jsonData in
            if let jsonData = jsonData {
                return try self.decoder.decode(IndexResponse.self, from: jsonData)
            }
            throw ElasticsearchError(identifier: "indexing_failed", reason: "Cannot update document", source: .capture(), statusCode: 404)
        }
    }

  /// Updates documents using a query
  ///
  /// - Parameters:
  ///   - index: The document index
  ///   - query: The query
  ///   - script: The Script to execute
  ///   - routing: Routing information
  ///   - version: Version information
  /// - Returns: A Future IndexResponse
  public func update(
    script: Script,
    query: Query,
    index: String,
    routing: String? = nil,
    version: Int? = nil,
    waitForCompletion: Bool = true
  ) -> Future<UpdateByQueryResponse>{
    let url = ElasticsearchClient.generateURL(path: "/\(index)/_update_by_query", routing: routing, version: version, waitForCompletion: waitForCompletion)
    let body: Data
    do {
      let wrappedScriptAndQuery = UpdateByQueryScript(script: script, query: query)
      body = try self.encoder.encode(wrappedScriptAndQuery)
    } catch {
      return worker.future(error: error)
    }
    return send(HTTPMethod.POST, to: url.string!, with: body).map(to: UpdateByQueryResponse.self) {jsonData in
      if let jsonData = jsonData {
        do {
          return try self.decoder.decode(UpdateByQueryResponse.self, from: jsonData)
        } catch {
          if waitForCompletion == false {
            do {
              let taskResponse = try self.decoder.decode(TaskResponse.self, from: jsonData)
              self.logger?.record(query: "Update by query task: \(taskResponse.task)")
            } catch {}
            // If this is waiting for a response, then we get a task number and no update details so return empty update response
            // This is a bit of a hack - we should really get the task id and return that instead
            return UpdateByQueryResponse(took: 0, timedOut: false, total: 0, updated: 0, batches: 0, versionConflicts: 0, noops: 0)
          }
        }
      }
      throw ElasticsearchError(identifier: "indexing_failed", reason: "Cannot update by query", source: .capture(), statusCode: 404)
    }
  }
  private struct UpdateByQueryScript: Codable {
    let script: Script
    let query: Query
    enum CodingKeys: String, CodingKey {
      case script
      case query
    }
    public init(script: Script,
                query: Query) {
      self.script = script
      self.query = query
    }
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(script, forKey: .script)
      try container.encode(query, forKey: .query)
    }
  }
  
  
    /// Delete the document with the given id
    ///
    /// - Parameters:
    ///   - index: The document index
    ///   - id: The document id
    ///   - routing: Routing information
    ///   - version: Version information
    /// - Returns: A Future IndexResponse
    public func delete(
        index: String,
        id: String,
        routing: String? = nil,
        version: Int? = nil
    ) -> Future<IndexResponse>{
        let url = ElasticsearchClient.generateURL(path: "/\(index)/_doc/\(id)", routing: routing, version: version)
        return send(HTTPMethod.DELETE, to: url.string!).map(to: IndexResponse.self) {jsonData in
            if let jsonData = jsonData {
                return try self.decoder.decode(IndexResponse.self, from: jsonData)
            }
            throw ElasticsearchError(identifier: "indexing_failed", reason: "Cannot delete document", source: .capture(), statusCode: 404)
        }
    }
  
  /// Delete documents using a query
  ///
  /// - Parameters:
  ///   - index: The document index
  ///   - query: The query
  ///   - routing: Routing information
  ///   - version: Version information
  /// - Returns: A Future IndexResponse
  public func delete(
    index: String,
    query: Query,
    routing: String? = nil,
    version: Int? = nil,
    waitForCompletion: Bool = true
  ) -> Future<DeleteByQueryResponse>{
    let url = ElasticsearchClient.generateURL(path: "/\(index)/_delete_by_query", routing: routing, version: version, waitForCompletion: waitForCompletion)
    let body: Data
    do {
      let wrappedScript: [String: Query] = [ "query" : query ]
      body = try self.encoder.encode(wrappedScript)
    } catch {
      return worker.future(error: error)
    }
    return send(HTTPMethod.POST, to: url.string!, with: body).map(to: DeleteByQueryResponse.self) {jsonData in
      if let jsonData = jsonData {
        do {
          return try self.decoder.decode(DeleteByQueryResponse.self, from: jsonData)
        } catch {
          if waitForCompletion == false {
            do {
              let taskResponse = try self.decoder.decode(TaskResponse.self, from: jsonData)
              self.logger?.record(query: "Delete by query task: \(taskResponse.task)")
            } catch {}
            // If this is waiting for a response, then we get a task number and no delete details so return empty delete response
            // This is a bit of a hack - we should really get the task id and return that instead
            return DeleteByQueryResponse(took: 0, timedOut: false, total: 0, deleted: 0, batches: 0, versionConflicts: 0, noops: 0)
          }
        }
      }
      throw ElasticsearchError(identifier: "indexing_failed", reason: "Cannot delete by query", source: .capture(), statusCode: 404)
    }
  }

}
