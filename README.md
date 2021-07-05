# SBPAsyncImage

Backport of [SwiftUI.AsyncImage](https://developer.apple.com/documentation/swiftui/asyncimage) to earlier iOS 15.  

AsyncImage is a view that asynchronously loads and displays an image.  
SBPAsyncImage provides like AsyncImage behavior and interface.  

## A Work In Progress

SBPAsyncImage is still in active development.  
Please file all bugs, issues, and suggestions as an Issue in the GitHub repository.  

## Installation

### [Swift Package Manager](https://swift.org/package-manager/)

```swift
// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SBPAsyncImageSample",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    dependencies: [
        .package(url: "https://github.com/yutailang0119/SBPAsyncImage", .branch("main")),
    ],
    targets: [
        .target(
            name: "SBPAsyncImageSample",
            dependencies: ["SBPAsyncImage"]),
    ]
)
```

## Usege

```swift
import SwiftUI
import SBPAsyncImage

struct ContentView: View {
    var body: some View {
        BackportAsyncImage(url: URL(string: "https://example.com/icon.png"))
            .frame(width: 200, height: 200)
    }
}
```

### Custom placeholder

```swift
import SwiftUI
import SBPAsyncImage

struct ContentView: View {
    var body: some View {
        BackportAsyncImage(url: URL(string: "https://example.com/icon.png")) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
        .frame(width: 50, height: 50)
    }
}
```

## Author

[Yutaro Muta](https://github.com/yutailang0119)
- muta.yutaro@gmail.com
- [@yutailang0119](https://twitter.com/yutailang0119)

## License

The project is available under [MIT Licence](./LICENSE)  
