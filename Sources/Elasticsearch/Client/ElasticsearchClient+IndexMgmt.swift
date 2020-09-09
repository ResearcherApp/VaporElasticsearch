
extension ElasticsearchClient {
    public func fetchIndex(name: String) -> Future<ElasticsearchIndex?> {
        return ElasticsearchIndex.fetch(indexName: name, client: self)
    }
    
    public func configureIndex(name: String) -> ElasticsearchIndex {
        return ElasticsearchIndex(indexName: name)
    }
    
    public func deleteIndex(name: String) -> Future<Void> {
        return ElasticsearchIndex.delete(indexName: name, client: self)
    }
}
