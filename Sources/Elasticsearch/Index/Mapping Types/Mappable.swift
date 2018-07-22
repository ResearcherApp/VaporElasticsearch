
public enum TextIndexOptions: String, Codable {
    case docs = "docs"
    case freqs = "freqs"
    case positions = "positions"
    case offsets = "offsets"
}

public enum SimilarityType: String, Codable {
    case bm25 = "BM25"
    case classic = "classic"
    case boolean = "boolean"
}

public enum TermVector: String, Codable {
    case no = "no"
    case yes = "yes"
    case withPositions = "with_positions"
    case withPositionsOffsets = "with_position_offsets"
}

public enum TextFieldType: String, Codable {
    case text = "text"
    case keyword = "keyword"
}

public struct TextField: Codable {
    var type: TextFieldType
    var analyzer: Analyzer?
    var normalizer: Normalizer?

    enum CodingKeys: String, CodingKey {
        case type
        case analyzer
        case normalizer
    }
    
    public init(
        type: TextFieldType,
        analyzer: Analyzer? = nil,
        normalizer: Normalizer? = nil) {

        self.type = type
        self.analyzer = analyzer
        self.normalizer = normalizer
    }
    
    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        if let analyzer = self.analyzer {
            try container.encodeIfPresent(analyzer.name, forKey: .analyzer)
        }
        if let normalizer = self.normalizer {
            try container.encodeIfPresent(normalizer.name, forKey: .normalizer)
        }
    }
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.type = try container.decode(TextFieldType.self, forKey: .type)
        let analyzer = try container.decodeIfPresent(String.self, forKey: .analyzer)
        if let analyzer = analyzer {
            self.analyzer = TempAnalyzer(name: analyzer)
        }
    }
}

public protocol Mappable: Codable {
    static var typeKey: MapType { get }
}
