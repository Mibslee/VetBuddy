import Foundation
import UIKit

/// ViewModel for poster preview, template selection, and share/save actions.
@MainActor
final class PosterViewModel: ObservableObject {

    @Published var selectedTemplate: PosterTemplate = .mountain
    @Published var posterImage: UIImage?
    @Published var isRendering: Bool = false

    private let renderer = PosterRenderer()
    private var renderTask: Task<Void, Never>?

    func renderPoster(data: PosterData) {
        renderTask?.cancel()
        isRendering = true
        let template = selectedTemplate

        renderTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 120_000_000)
            guard !Task.isCancelled, let self else { return }

            let image = self.renderer.render(template: template, data: data)
            guard !Task.isCancelled else { return }

            self.posterImage = image
            self.isRendering = false
        }
    }

    func saveToPhotos() -> Bool {
        guard let image = posterImage else { return false }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        return true
    }
}
