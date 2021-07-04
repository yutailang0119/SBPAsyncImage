import SwiftUI

struct BackportAsyncImage<Content: View>: View {
    @ObservedObject private var viewModel: ViewModel
    private let content: (AsyncImagePhase) -> Content

    init(url: URL?,
         scale: CGFloat,
         transaction: Transaction,
         @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self._viewModel = ObservedObject(initialValue: ViewModel(url: url, transaction: transaction))
        self.content = content
        viewModel.download()
    }

    var body: some View {
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
        URL(string: "http://httpbin.org/image/webp")
    }

    static var previews: some View {
        BackportAsyncImage(
            url: url,
            scale: 1.0,
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
