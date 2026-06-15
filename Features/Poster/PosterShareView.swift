import SwiftUI

/// UIViewControllerRepresentable wrapper for UIActivityViewController (iOS Share Sheet).
struct PosterShareView: UIViewControllerRepresentable {

    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {
        // No updates needed
    }
}
