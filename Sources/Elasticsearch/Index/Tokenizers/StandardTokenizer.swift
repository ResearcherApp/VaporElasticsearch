
import Foundation

public struct StandardTokenizer: Tokenizer {
    /// :nodoc:
    public static var typeKey = TokenizerType.standard
    
    let type = typeKey.rawValue
    
    public let name: String
    public var maxTokenLength: Int? = nil
    
    var isCustom = false
    
    enum CodingKeys: String, CodingKey {
        case type
        case maxTokenLength = "max_token_length"
    }
    
    public init() {
        self.name = type
        self.isCustom = false
    }
    
    public init(name: String, maxTokenLength: Int? = nil) {
        self.name = name
        self.maxTokenLength = maxTokenLength
        self.isCustom = true
    }
    
    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        if self.isCustom {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encode(maxTokenLength, forKey: .maxTokenLength)
        }
        else {
            var container = encoder.singleValueContainer()
            try container.encode(type)
        }
    }
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (decoder.codingPath.last?.stringValue)!
    
        self.maxTokenLength = try container.decodeIfPresent(Int.self, forKey: .maxTokenLength)
    }
}