import SwiftUI

public struct BackportAsyncImage<Content: View>: View {
    @ObservedObject private var viewModel: ViewModel
    private let content: (AsyncImagePhase) -> Content

    public init(url: URL?, scale: CGFloat = 1) where Content == Image {
        self.viewModel = ViewModel(url: url, transaction: Transaction())
        self.content = { $0.image ?? Image("") }
        self.viewModel.download()
    }

    public init<I, P>(url: URL?,
                      scale: CGFloat = 1,
                      @ViewBuilder content: @escaping (Image) -> I,
                      @ViewBuilder placeholder: @escaping () -> P) where Content == _ConditionalContent<I, P>, I : View, P : View {
        self.viewModel = ViewModel(url: url, transaction: Transaction())
        self.content = { phase -> _ConditionalContent<I, P> in
            if let image = phase.image {
                return ViewBuilder.buildEither(first: content(image))
            } else {
                return ViewBuilder.buildEither(second: placeholder())
            }
        }
        self.viewModel.download()
    }

    public init(url: URL?,
                scale: CGFloat = 1,
                transaction: Transaction = Transaction(),
                @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.viewModel = ViewModel(url: url, transaction: transaction)
        self.content = content
        self.viewModel.download()
    }

    public var body: some View {
        content(viewModel.phase)
    }
}

extension BackportAsyncImage {
    private final class ViewModel: ObservableObject {
        private let url: URL?
        private let transaction: Transaction
        @Published var phase: AsyncImagePhase

        init(url: URL?, transaction: Transaction) {
            self.url = url
            self.transaction = transaction
            self.phase = .empty
        }

        func download() {
            guard let url = url else {
                return
            }
            URLSession.shared.dataTask(with: url) { data, _, error in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    if let error = error {
                        self.phase = .failure(error)
                        return
                    }

                    withTransaction(self.transaction) {
                        self.phase = data
                            .flatMap(self.image(from:))
                            .map{ AsyncImagePhase.success($0) }
                            ?? .empty
                    }
                }
            }
            .resume()
        }

        private func image(from data: Data?) -> Image? {
            #if os(macOS)
            return data
                .flatMap(NSImage.init(data:))
                .map(Image.init(nsImage:))
            #else
            return data
                .flatMap(UIImage.init(data:))
                .map(Image.init(uiImage:))
            #endif
        }
    }
}

struct BackportAsyncImage_Previews: PreviewProvider {
    static var url: URL? {
        URL(string: "http://httpbin.org/image/png")
    }

    static var previews: some View {
        VStack {
            BackportAsyncImage(url: url)
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
