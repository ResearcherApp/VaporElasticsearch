// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Elasticsearch",
    platforms: [
      .macOS(.v10_15)
    ],
    products: [
        .library(name: "Elasticsearch", targets: ["Elasticsearch"])
    ],
    dependencies: [
		// Core extensions, type-aliases, and functions that facilitate common tasks.
		.package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),

		// Core services for creating database integrations.
		//.package(url: "https://github.com/vapor/database-kit.git", from: "1.0.0"),

		// Event-driven network application framework for high performance protocol servers & clients, non-blocking.
		//.package(url: "https://github.com/apple/swift-nio.git", from: "1.0.0"),

		// Grab the HTTP goodies from Vapor
		//.package(url: "https://github.com/vapor/http.git", from: "4.0.0"),

		// Grab Vapor itself for testing
		//.package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
    ],
    targets: [
        .target( name: "Elasticsearch", dependencies: [
		//.product(name: "HTTP", package: "http"),
		.product(name: "Vapor", package: "vapor")
	]),
        .testTarget( name: "ElasticsearchTests", dependencies: [
		//.product(name: "HTTP", package: "http"),
		.product(name: "Vapor", package: "vapor"),
		.target(name: "Elasticsearch")
	])
    ]
)
