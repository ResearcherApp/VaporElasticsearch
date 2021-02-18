
import Foundation
import HTTP

extension ElasticsearchClient {
    /// Creates a new bulk operation.
    ///
    /// [Here's more information on bulk operations](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html)
    ///
    /// - Parameter capacity: This is the estimated number of bytes for the body of the request. Defaults to 10MB.
    /// - Returns: Returns an `ElasticsearchBulk` class for adding operations to.
    public func bulkOperation(estimatedBodySize capacity: Int = 10 * 1024 * 1024)  -> ElasticsearchBulk {
        return ElasticsearchBulk(client: self, estimatedBodySize: capacity)
    }
}


/// Configures the header used for each bulk operation
public struct BulkHeader: Encodable {
    /// The index to use
    public var index: String?
    /// The document id
    public var id: String?
    /// Routing information
    public var routing: String?
    /// Document version
    public var version: Int?
    /// Number of retry attempts (only used in `update` commands)
    public var retryOnConflict: Int?

    enum CodingKeys: String, CodingKey {
        case index = "_index"
        case id = "_id"
        case routing = "routing"
        case version = "version"
        case retryOnConflict = "retry_on_conflict"
    }
}

/// Bulk operation management.
///
/// [Here's more information on bulk operations](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html)
public class ElasticsearchBulk {
    var requestBody:Data
    let encoder = JSONEncoder()
    let client: ElasticsearchClient

    /// Allows default values to be applied to all bulk operations.
    ///
    /// This is useful in cases where all (or the majority) of the opeations you perform should be performed on the same index, type, etc.
    /// If values are provided in the operation calls (`index`, `create`, `update`, `delete`) those values override the values provided here.
    public var defaultHeader: BulkHeader = BulkHeader(index: nil, id: nil, routing: nil, version: nil, retryOnConflict: nil)

    /// Creates a new bulk operation object.
    ///
    /// - Parameters:
    ///   - client: The client to issue the bulk operation on
    ///   - capacity: The estimated size of the total body in bytes
    init(client: ElasticsearchClient, estimatedBodySize capacity: Int) {
        self.client = client
        requestBody = Data(capacity: capacity)
    }

    /// Add a document to be indexed to the bulk operation
    ///
    /// - Parameters:
    ///   - doc: The document to be indexed
    ///   - index: The index to put the document into
    ///   - id: The id to use for the document
    ///   - routing: Routing information
    ///   - version: Version information
    /// - Throws: Can throw errors if there are issues encoding the doc.
    public func index<T: Codable>(
        doc :T,
        index: String? = nil,
        id: String? = nil,
        routing: String? = nil,
        version: Int? = nil
        ) throws {
        let header = ["index": mergeHeaders(defaultHeader, BulkHeader(index: index, id: id, routing: routing, version: version, retryOnConflict: nil))]
        // Add the header to the request body followed by a newline character (newline -> 10)
        requestBody.append(try encoder.encode(header))
        requestBody.append(10)

        // Add the document to the request body followed by a newline character (newline -> 10)
        requestBody.append(try encoder.encode(doc))
        requestBody.append(10)
    }

    /// Add a document to be created to the bulk operation
    ///
    /// - Parameters:
    ///   - doc: The document to be created
    ///   - index: The index to put the document into
    ///   - id: The id to use for the document
    ///   - routing: Routing information
    ///   - version: Version information
    /// - Throws: Can throw errors if there are issues encoding the doc.
    public func create<T: Codable>(
        doc :T,
        index: String? = nil,
        id: String? = nil,
        routing: String? = nil,
        version: Int? = nil
        ) throws {
        let header = ["create": mergeHeaders(defaultHeader, BulkHeader(index: index, id: id, routing: routing, version: version, retryOnConflict: nil))]
        // Add the header to the request body followed by a newline character (newline -> 10)
        requestBody.append(try encoder.encode(header))
        requestBody.append(10)

        // Add the document to the request body followed by a newline character (newline -> 10)
        requestBody.append(try encoder.encode(doc))
        requestBody.append(10)
    }

    /// Add a document to be updated to the bulk operation
    ///
    /// - Parameters:
    ///   - doc: The document to be updated
    ///   - index: The index to put the document into
    ///   - id: The id to use for the document
    ///   - routing: Routing information
    ///   - version: Version information
    /// - Throws: Can throw errors if there are issues encoding the doc.
    public func update<T: Codable>(
        doc: T,
        index: String? = nil,
        id: String? = nil,
        routing: String? = nil,
        version: Int? = nil,
        retryOnConflict: Int? = nil,
        prewrapped: Bool = false
        ) throws {
        let header = ["update": mergeHeaders(defaultHeader, BulkHeader(index: index, id: id, routing: routing, version: version, retryOnConflict: retryOnConflict))]
        // Add the header to the request body followed by a newline character (newline -> 10)
        requestBody.append(try encoder.encode(header))
        requestBody.append(10)

        // Add the document to the request body followed by a newline character (newline -> 10)
      if prewrapped {
        requestBody.append(try encoder.encode(doc))
      }
      else {
        let wrappedDoc: [String: T] = [ "doc": doc ]
        requestBody.append(try encoder.encode(wrappedDoc))
      }
        
        requestBody.append(10)
    }

  /// Add a script to be run in the bulk operation
  ///
  /// - Parameters:
  ///   - script: The script to be run
  ///   - index: The index to put the document into
  ///   - id: The id to use for the document
  ///   - routing: Routing information
  ///   - version: Version information
  /// - Throws: Can throw errors if there are issues encoding the doc.
  public func update(
    script: Script,
    index: String? = nil,
    id: String? = nil,
    routing: String? = nil,
    version: Int? = nil,
    retryOnConflict: Int? = nil
  ) throws {
    let header = ["update": mergeHeaders(defaultHeader, BulkHeader(index: index, id: id, routing: routing, version: version, retryOnConflict: retryOnConflict))]
    // Add the header to the request body followed by a newline character (newline -> 10)
    requestBody.append(try encoder.encode(header))
    requestBody.append(10)
    
    // Add the script to the request body followed by a newline character (newline -> 10)
    let wrappedScript: [String: Script] = [ "script": script ]
    requestBody.append(try encoder.encode(wrappedScript))
    requestBody.append(10)
  }

    /// Add a document to be deleted by the bulk operation
    ///
    /// - Parameters:
    ///   - id: The id of the document to be deleted
    ///   - index: The index where the document is located at
    ///   - routing: Routing information
    ///   - version: Version information
    /// - Throws: Can throw errors if there are issues encoding the doc.
    public func delete(
        id: String? = nil,
        index: String? = nil,
        routing: String? = nil,
        version: Int? = nil
        ) throws {
        let header = ["delete": mergeHeaders(defaultHeader, BulkHeader(index: index, id: id, routing: routing, version: version, retryOnConflict: nil))]
        // Add the header to the request body followed by a newline character (newline -> 10)
        requestBody.append(try encoder.encode(header))
        requestBody.append(10)
    }

    /// Executes the bulk operation
    ///
    /// - Returns: Returns the response from the bulk operation
  public func send(ignoreErrors: Bool = false) throws -> Future<BulkResponse> {
    // Add on a newline at the end to signal the end of the commands
    requestBody.append(10)
    
    let url = ElasticsearchClient.generateURL(path: "/_bulk")
    var request = HTTPRequest(method: HTTPMethod.POST, url: url.string!, body: HTTPBody(data: requestBody))
    request.headers.add(name: "Content-Type", value: "application/x-ndjson")
    
    return client.send(request).map(to: BulkResponse.self) {jsonData in
      if let jsonData = jsonData {
        do {
          return try JSONDecoder().decode(BulkResponse.self, from: jsonData)
        }
        catch {
          if ignoreErrors {
            return BulkResponse(took: 0, errors: true, items: [BulkItemResponse]())
          }
        }
      }
      
      throw ElasticsearchError(identifier: "bulk_failed", reason: "Unexpected failure", source: .capture(), statusCode: 404)
    }
  }
  
    private func mergeHeaders(_ base: BulkHeader, _ override: BulkHeader) -> BulkHeader {
        return BulkHeader(index: override.index ?? base.index,
                          id: override.id ?? base.id,
                          routing: override.routing ?? base.routing,
                          version: override.version ?? base.version,
                          retryOnConflict: override.retryOnConflict ?? base.retryOnConflict)
    }
}
