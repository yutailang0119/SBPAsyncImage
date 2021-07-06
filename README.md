# SBPAsyncImage

<p align="left">
  <a href="https://developer.apple.com/swift"><img alt="Swift 5.4" src="https://img.shields.io/badge/Swift-5.4-orange.svg?style=flat"/></a>
  <a href="https://developer.apple.com/xcode/swiftui/"><img alt="SwiftUI" src="https://img.shields.io/badge/SwiftUI-blue.svg?style=flat"/></a>
  <a href="https://swift.org/package-manager/"><img alt="Swift Package Manager" src="https://img.shields.io/badge/Swift_Package_Manager-compatible-green.svg?style=flat"/></a>
  <a href="https://github.com/yutailang0119/SBPAsyncImage/blob/main/LICENSE"><img alt="Lincense" src="https://img.shields.io/badge/license-MIT-black.svg?style=flat"/></a>
</p>

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
    name: "SBPAsyncImageExample",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    dependencies: [
        .package(url: "https://github.com/yutailang0119/SBPAsyncImage", .exact("0.1.0")),
    ],
    targets: [
        .target(
            name: "SBPAsyncImageExample",
            dependencies: ["SBPAsyncImage"]),
    ]
)
```

## Usage

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
