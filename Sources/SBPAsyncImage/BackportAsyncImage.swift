import SwiftUI

@available(iOS, deprecated: 15.0, renamed: "SwiftUI.AsyncImage")
@available(macOS, deprecated: 12.0, renamed: "SwiftUI.AsyncImage")
@available(tvOS, deprecated: 15.0, renamed: "SwiftUI.AsyncImage")
@available(watchOS, deprecated: 8.0, renamed: "SwiftUI.AsyncImage")
public struct BackportAsyncImage<Content: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content

    public init(url: URL?, scale: CGFloat = 1) where Content == Image {
        self.url = url
        self.scale = scale
        self.transaction = Transaction()
        self.content = { $0.image ?? Image("") }
    }

    public init<I, P>(url: URL?,
                      scale: CGFloat = 1,
                      @ViewBuilder content: @escaping (Image) -> I,
                      @ViewBuilder placeholder: @escaping () -> P) where Content == _ConditionalContent<I, P>, I : View, P : View {
        self.url = url
        self.scale = scale
        self.transaction = Transaction()
        self.content = { phase -> _ConditionalContent<I, P> in
            if let image = phase.image {
                return ViewBuilder.buildEither(first: content(image))
            } else {
                return ViewBuilder.buildEither(second: placeholder())
            }
        }
    }

    public init(url: URL?,
                scale: CGFloat = 1,
                transaction: Transaction = Transaction(),
                @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }

    public var body: some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            ContentBody(url: url,
                        scale: scale,
                        transaction: transaction,
                        content: content)
        } else {
            ContentCompatBody(url: url,
                              scale: scale,
                              transaction: transaction,
                              content: content)
        }
    }
}

private final class ViewModel: ObservableObject {
    @Published var phase: AsyncImagePhase

    init() {
        self.phase = .empty
    }

    func download(url: URL?,
                  scale: CGFloat,
                  transaction: Transaction) {
        guard let url = url,
              case(.empty) = phase else {
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    self?.phase = .failure(error)
                    return
                }

                withTransaction(transaction) {
                    self?.phase = self?.image(from: data, scale: scale)
                        .map{ AsyncImagePhase.success($0) }
                        ?? .empty
                }
            }
        }
        .resume()
    }

    private func image(from data: Data?, scale: CGFloat) -> Image? {
        #if os(macOS)
        // TODO: Support scale on macOS
        return data
            .flatMap(NSImage.init(data:))
            .map(Image.init(nsImage:))
        #else
        return data
            .flatMap { UIImage(data: $0, scale: scale) }
            .map(Image.init(uiImage:))
        #endif
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct ContentBody<Content: View>: View {
    @StateObject private var viewModel = ViewModel()
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content

    init(url: URL?,
         scale: CGFloat,
         transaction: Transaction,
         @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }

    var body: some View {
        content(viewModel.phase)
            .onAppear {
                viewModel.download(url: url, scale: scale, transaction: transaction)
            }
    }
}

@available(iOS, deprecated: 14.0)
@available(macOS, deprecated: 11.0)
@available(tvOS, deprecated: 14.0)
@available(watchOS, deprecated: 7.0)
private struct ContentCompatBody<Content: View>: View {
    struct Body: View {
        @ObservedObject private var viewModel: ViewModel
        private let content: (AsyncImagePhase) -> Content

        init(viewModel: ViewModel,
             url: URL?,
             scale: CGFloat,
             transaction: Transaction,
             @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
            self.viewModel = viewModel
            self.content = content
            self.viewModel.download(url: url, scale: scale, transaction: transaction)
        }

        var body: some View {
            content(viewModel.phase)
        }
    }

    @State private var viewModel = ViewModel()
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content

    init(url: URL?,
         scale: CGFloat,
         transaction: Transaction,
         @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }

    var body: Body {
        Body(viewModel: viewModel,
             url: url,
             scale: scale,
             transaction: transaction,
             content: content)
    }
}

struct BackportAsyncImage_Previews: PreviewProvider {
    static var url: URL? {
        URL(string: "http://httpbin.org/image/png")
    }

    static var previews: some View {
        VStack {
            BackportAsyncImage(url: url, scale: 2.0)
                .frame(width: 100, height: 100)

            BackportAsyncImage(
                url: url,
                content: {
                    $0
                        .resizable()
                        .clipShape(Circle())
                },
                placeholder: {
                    Color.black
                }
            )
            .frame(width: 100, height: 100)

            BackportAsyncImage(
                url: url,
                transaction: Transaction(animation: .linear),
                content: { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else if phase.error != nil {
                        Color.red
                    } else {
                        Color.blue
                    }
                }
            )
            .frame(width: 100, height: 100)
        }
    }
}
