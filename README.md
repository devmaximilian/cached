# Cached

This library aims to be a lightweight wrapper for caching `Codable` types.

## Installation

### Swift Package Manager

Add Cached as a dependency by including it under `dependencies` in the package manifest file, `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/devmaximilian/cached.git", from: "x.x.x")
]
```

## Usage

```swift
struct Article: Codable {
    let title: String
    let description: String
}

class Service {
    init() {}

    @Cached(key: "articles", defaultValue: [], ttl: .minutes(30))
    var articles: [Article]
}
```


## License

Cached is released under the MIT license. See [LICENSE](https://github.com/devmaximilian/cached/blob/master/LICENSE) for details.
