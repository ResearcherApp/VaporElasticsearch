import XCTest
@testable import Elasticsearch

struct TestModel: Codable, SettableID {
    init(name: String, number: Int) {
        self.name = name
        self.number = number
    }

    var id: String?
    var name: String
    var number: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case number
    }
    
    mutating func setID(_ id: String) {
        self.id = id
    }
}

final class ElasticsearchTests: XCTestCase {
    func testIndexCreation() throws {
        let es = try ElasticsearchClient.makeTest()
        defer { es.close() }
        
        try es.deleteIndex(name: "test").wait()
        
        let analyzer = StandardAnalyzer(name: "std_english", stopwords: ["_english_"])
        
        let indexConfig = es.configureIndex(name: "test")
            .property(key: "name", type: MapText(analyzer: analyzer))
            .property(key: "number", type: MapInteger())
            .alias(name: "testalias")
            .indexSettings(IndexSettings(shards: 3, replicas: 2))
            .add(metaKey: "Foo", metaValue: "Bar")
        
        let _ = try indexConfig.create(client: es).wait()
        
        let index = try es.fetchIndex(name: "test").wait()
        if let index = index {
            XCTAssertEqual(index.aliases.count, 1, "Incorrect number of aliases")
            XCTAssertNotNil(index.aliases["testalias"], "testalias does not exist")
            XCTAssertEqual(index.settings.index?.numberOfShards, 3, "Incorrect number of shards")
            XCTAssertEqual(index.settings.index?.numberOfReplicas, 2, "Incorrect number of replicas")
            XCTAssertEqual(index.mapping.doc.meta?.userDefined!["Foo"], "Bar", "User metadata")

            // TODO: Should test for more than just the existance of the properties
            let nameProp = index.mapping.doc.properties["name"]
            let numberProp = index.mapping.doc.properties["number"]
            XCTAssertNotNil(nameProp, "Could not find name property")
            XCTAssertNotNil(numberProp, "Could not find number property")
        }
        else {
            XCTFail("Index not found")
        }
        try es.deleteIndex(name: "test").wait()
    }
    
    func testCRUD() throws {
        let es = try ElasticsearchClient.makeTest()
        defer { es.close() }
        
        try es.deleteIndex(name: "test").wait()

        let _ = try es.configureIndex(name: "test")
            .property(key: "name", type: MapText())
            .property(key: "number", type: MapInteger())
            .alias(name: "testalias")
            .indexSettings(IndexSettings(shards: 3, replicas: 2))
            .create(client: es).wait()
        
        var indexDoc: TestModel = TestModel(name: "bar", number: 26)
        var response = try es.index(doc: indexDoc, index: "test").wait()
        indexDoc.id = response.id

        
        if var fetchedDoc = try es.get(decodeTo: TestModel.self, index: "test", id: indexDoc.id!).wait() {
            XCTAssertEqual(indexDoc.name, fetchedDoc.source.name, "Saved and fetched names do not match")
            XCTAssertEqual(indexDoc.number, fetchedDoc.source.number, "Saved and fetched numbers do not match")

            fetchedDoc.source.name = "baz"
            response = try es.index(doc: fetchedDoc.source, index: "test", id: fetchedDoc.id).wait()
            
            sleep(2)
            
            if let fetchedDoc = try es.get(decodeTo: TestModel.self, index: "test", id: fetchedDoc.id).wait() {
                XCTAssertEqual(fetchedDoc.source.name, "baz", "Updated name does not match")
                
                sleep(2)
                
                let query = SearchContainer(
                    Query(
                        MatchAll()
                    )
                )
                
                let searchResults = try es.search(decodeTo: TestModel.self, index: "test", query: query).wait()
                XCTAssertEqual(searchResults.hits!.total, 1, "Should have found one result")
                XCTAssertEqual(searchResults.hits!.hits.first?.source.name, fetchedDoc.source.name, "Did not fetch correct document")
                
                let _ = es.delete(index: "test", id: fetchedDoc.id)
            }
            else {
                XCTFail("Could not fetch document")
            }
        }
        else {
            XCTFail("Could not fetch document")
        }
        
        try es.deleteIndex(name: "test").wait()
    }
    
    func testBulk() throws {
        let es = try ElasticsearchClient.makeTest()
        defer { es.close() }
        
        try es.deleteIndex(name: "test").wait()

        let _ = try es.configureIndex(name: "test")
            .property(key: "name", type: MapText())
            .property(key: "number", type: MapInteger())
            .alias(name: "testalias")
            .indexSettings(IndexSettings(shards: 3, replicas: 2))
            .create(client: es).wait()
        
        var doc0: TestModel = TestModel(name: "foo", number: 26)
        let doc1: TestModel = TestModel(name: "bar", number: 27)
        let doc2: TestModel = TestModel(name: "baz", number: 28)
        
        let response = try es.index(doc: doc0, index: "test").wait()
        doc0.id = response.id
        
        let bulk = es.bulkOperation()
        bulk.defaultHeader.index = "test"
        try bulk.index(doc: doc1)
        try bulk.index(doc: doc2)
        try bulk.delete(id: doc0.id!)
        let bulkResponse = try bulk.send().wait()
        
        XCTAssert(bulkResponse.errors == false, "There were errors in the bulk request")
    }
    
    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        let thisClass = type(of: self)
        let linuxCount = thisClass.allTests.count
        let darwinCount = Int(thisClass.defaultTestSuite.testCaseCount)
        XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }
    
    static var allTests = [
        ("testIndexCreation", testIndexCreation),
        ("testCRUD", testCRUD),
        ("testBulk", testBulk),
        
        ("testLinuxTestSuiteIncludesAllTests",      testLinuxTestSuiteIncludesAllTests)
    ]
}
