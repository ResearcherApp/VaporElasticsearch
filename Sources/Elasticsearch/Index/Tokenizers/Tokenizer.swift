import Foundation


public protocol Tokenizer: Codable {
    static var typeKey: TokenizerType { get }
    var name: String { get }
}

/// :nodoc:
public enum TokenizerType: String, Codable {
    case none
    case standard
    case letter
    case lowercase
    case whitespace
    case UAXURLEmail = "uax_url_email"
    case classic
    case thai
    case ngram
    case edgengram = "edge_ngram"
    case keyword
    case pattern
    case simplePattern = "simple_pattern"
    case simplePatternSplit = "simple_pattern_split"
    case pathHierarchy = "path_hierarchy"
    
    var metatype: Tokenizer.Type {
        switch self {
        case .none:
            return TempTokenizer.self
        case .standard:
            return StandardTokenizer.self
        case .letter:
            return LetterTokenizer.self
        case .lowercase:
            return LowercaseTokenizer.self
        case .whitespace:
            return WhitespaceTokenizer.self
        case .UAXURLEmail:
            return UAXURLEmailTokenizer.self
        case .classic:
            return ClassicTokenizer.self
        case .thai:
            return ThaiTokenizer.self
        case .ngram:
            return NGramTokenizer.self
        case .edgengram:
            return EdgeNGramTokenizer.self
        case .keyword:
            return KeywordTokenizer.self
        case .pattern:
            return PatternTokenizer.self
        case .simplePattern:
            return SimplePatternTokenizer.self
        case .simplePatternSplit:
            return SimplePatternSplitTokenizer.self
        case .pathHierarchy:
            return PathHierarchyTokenizer.self
        }
    }
}

/// :nodoc:
public struct AnyTokenizer : Codable {
    var base: Tokenizer
    
    init(_ base: Tokenizer) {
        self.base = base
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)
        
        let type = try container.decode(TokenizerType.self, forKey: DynamicKey(stringValue: "type")!)
        self.base = try type.metatype.init(from: decoder)
    }
    
    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
    }
}

/// :nodoc:
internal struct TempTokenizer: Tokenizer {
    /// :nodoc:
    public static var typeKey = TokenizerType.none
    
    let type = typeKey.rawValue
    /// :nodoc:
    public let name: String
    
    internal init(name: String) {
        self.name = name
    }
}
