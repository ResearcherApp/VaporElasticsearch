import Foundation

public struct Suggest: Encodable {
    public let name: String
    public let prefix: String
    public let field: String
  public let contexts: [String: [String]]?

  public init(name: String, prefix: String, field: String, contexts: [String: [String]]? = nil) {
        self.name = name
        self.prefix = prefix
        self.field = field
    self.contexts = contexts
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var completion = container.nestedContainer(keyedBy: CompletionKeys.self, forKey: .completion)

        try container.encode(prefix, forKey: .prefix)
        try completion.encode(field, forKey: .field)
      try completion.encodeIfPresent(contexts, forKey: .contexts)
    }

    enum CodingKeys: String, CodingKey {
        case prefix
        case completion
    }

    enum CompletionKeys: String, CodingKey {
        case field
      case contexts
    }
}
