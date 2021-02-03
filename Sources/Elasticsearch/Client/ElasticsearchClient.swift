import HTTP
import DatabaseKit

/// A Elasticsearch client.
public final class ElasticsearchClient: DatabaseConnection, BasicWorker {
  public typealias Database = ElasticsearchDatabase
  
  /// See `BasicWorker`.
  public var eventLoop: EventLoop {
    return worker.eventLoop
  }
  
  /// See `DatabaseConnection`.
  public var isClosed: Bool
  
  /// If non-nil, will log requests/reponses.
  public var logger: DatabaseLogger?
  
  /// See `Extendable`.
  public var extend: Extend
  
  /// The HTTP connection
  private let esConnection: HTTPClient
  
  public let worker: Worker
  internal let encoder = JSONEncoder()
  internal let decoder = JSONDecoder()
  internal var isConnected: Bool
  
  internal let config: ElasticsearchClientConfig
  
  /// Creates a new Elasticsearch client.
  init(client: HTTPClient, config: ElasticsearchClientConfig, worker: Worker) {
    self.esConnection = client
    self.extend = [:]
    self.isClosed = false
    self.isConnected = false
    self.config = config
    self.worker = worker
  }
  
  /// Closes this client.
  public func close() {
    self.isClosed = true
    esConnection.close().do() {
      self.isClosed = true
      self.isConnected = false
    }.catch() { error in
      self.isClosed = true
      self.isConnected = false
    }
  }
  
  internal static func generateURL(
    path: String,
    routing: String? = nil,
    version: Int? = nil,
    storedFields: [String]? = nil,
    realtime: Bool? = nil,
    forceCreate: Bool? = nil,
    scroll: ScrollKeepAlive? = nil,
    waitForCompletion: Bool = true
  ) -> URLComponents {
    var url = URLComponents()
    url.path = path
    var query = [URLQueryItem]()
    if routing != nil {
      query.append(URLQueryItem(name: "routing", value: routing))
    }
    if version != nil {
      query.append(URLQueryItem(name: "version", value: "\(version!)"))
    }
    if storedFields != nil {
      query.append(URLQueryItem(name: "stored_fields", value: storedFields?.joined(separator: ",")))
    }
    if realtime != nil {
      query.append(URLQueryItem(name: "realtime", value: realtime! ? "true" : "false"))
    }
    if scroll != nil {
      query.append(URLQueryItem(name: "scroll", value: "\(scroll!.rawValue)"))
    }
    if !waitForCompletion {
      query.append(URLQueryItem(name: "wait_for_completion", value: "false"))
    }
    url.queryItems = query
    
    return url
  }
  
  public func send(
    _ method: HTTPMethod,
    to path: String
  ) -> Future<Data?> {
    let httpReq = HTTPRequest(method: method, url: path)
    return send(httpReq)
  }
  
  public func send(
    _ method: HTTPMethod,
    to path: String,
    with body: Dictionary<String, Any>
  ) -> Future<Data?> {
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
      return send(method, to: path, with: jsonData)
    } catch {
      return worker.future(error: error)
    }
  }
  
  public func send(
    _ method: HTTPMethod,
    to path: String,
    with body: Data
  ) -> Future<Data?> {
    let httpReq = HTTPRequest(method: method, url: path, body: HTTPBody(data: body))
    return send(httpReq)
  }
  
  public func send(
    _ request: HTTPRequest
  ) -> Future<Data?> {
    var request = request
    if request.headers.contains(name: "Content-Type") == false {
      request.headers.add(name: "Content-Type", value: "application/json")
    }
    if self.config.username != nil && self.config.password != nil {
      let token = "\(config.username!):\(config.password!)".data(using: String.Encoding.utf8)?.base64EncodedString()
      if token != nil {
        request.headers.add(name: "Authorization", value: "Basic \(token!)")
      }
    }
    
    logger?.record(query: request.description)
    
    return self.esConnection.send(request).map(to: Data?.self) { response in

      self.logger?.record(query: response.description)

      if response.body.data == nil {
        throw ElasticsearchError(identifier: "empty_response", reason: "Missing response body from Elasticsearch", source: .capture())
      }
      
      if response.status.code >= 400 {
        guard let json = try JSONSerialization.jsonObject(with: response.body.data!, options: []) as? [String: Any] else {
          throw ElasticsearchError(identifier: "invalid_response", reason: "Cannot parse response body from Elasticsearch", source: .capture())
        }
        
        if response.status.code == 404 {
          return nil
        }
        
        let error = json["error"] != nil ? (json["error"] as! Dictionary<String, Any>).description : ""
        throw ElasticsearchError(identifier: "elasticsearch_error", reason: error, source: .capture(), statusCode: response.status.code)
      }
      
      let bodyString = String(data: response.body.data!, encoding: String.Encoding.utf8) as String?
      self.logger?.record(query: bodyString ?? "")
      
      return response.body.data!
    }
  }
}
