import SwiftUI

@available(iOS, deprecated: 15.0, renamed: "SwiftUI.AsyncImagePhase")
@available(macOS, deprecated: 12.0, renamed: "SwiftUI.AsyncImagePhase")
@available(tvOS, deprecated: 15.0, renamed: "SwiftUI.AsyncImagePhase")
@available(watchOS, deprecated: 8.0, renamed: "SwiftUI.AsyncImagePhase")
public enum AsyncImagePhase {
    case empty
    case success(Image)
    case failure(Error)

    public var image: Image? {
        switch self {
        case .empty, .failure:
            return nil
        case .success(let image):
            return image
        }
    }

    public var error: Error? {
        switch self {
        case .empty, .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}
