import SwiftUI

struct BackportAsyncImage<Content: View>: View {
    @ObservedObject private var viewModel: ViewModel
    private let content: (AsyncImagePhase) -> Content

    init(url: URL?,
         scale: CGFloat = 1,
         @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self._viewModel = ObservedObject(initialValue: ViewModel(url: url))
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
        @Published var phase: AsyncImagePhase

        init(url: URL?) {
            self.url = url
            self.phase = .empty
        }

        func download() {
            guard let url = url else {
                return
            }
            URLSession.shared.dataTask(with: url) { data, _, error in
                DispatchQueue.main.async { [weak self] in
                    if let error = error {
                        self?.phase = .failure(error)
                        return
                    }

                    self?.phase = data
                        .flatMap(UIImage.init(data:))
                        .map(Image.init(uiImage:))
                        .map{ AsyncImagePhase.success($0) }
                    ?? .empty
                }
            }
            .resume()
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
