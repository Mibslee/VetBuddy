import SwiftUI

/// Poster preview with template selection and save/share actions.
struct PosterPreviewView: View {

    @StateObject private var viewModel = PosterViewModel()

    let data: PosterData

    @State private var showShareSheet = false
    @State private var showSaveAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                templateSelector
                posterPreview
                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Color.vbCream.ignoresSafeArea())
        .navigationTitle("生成海报")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.renderPoster(data: data) }
        .onChange(of: viewModel.selectedTemplate) { _, _ in
            viewModel.renderPoster(data: data)
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = viewModel.posterImage {
                PosterShareView(image: image)
            }
        }
        .alert("已保存", isPresented: $showSaveAlert) {
            Button("好的", role: .cancel) {}
        } message: {
            Text("海报已保存到相册")
        }
    }

    // MARK: - Template Selector

    private var templateSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择模板")
                .vbHeadline()

            HStack(spacing: 12) {
                ForEach(PosterTemplate.allCases) { template in
                    templateTab(template)
                }
            }
        }
    }

    private func templateTab(_ template: PosterTemplate) -> some View {
        Button {
            viewModel.selectedTemplate = template
        } label: {
            Text(template.name)
                .font(VBFont.body)
                .foregroundStyle(
                    viewModel.selectedTemplate == template
                        ? .white
                        : Color.vbMainText
                )
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(
                    viewModel.selectedTemplate == template
                        ? Color.vbAccent
                        : Color.vbCardBackground
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Poster Preview

    private var posterPreview: some View {
        Group {
            if viewModel.isRendering {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.vbCardBackground)
                        .frame(height: 400)
                    ProgressView("渲染中...")
                }
            } else if let image = viewModel.posterImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.vbCardBackground)
                    .frame(height: 400)
                    .overlay(
                        Text("无法生成海报")
                            .vbBody()
                            .foregroundStyle(Color.vbSecondaryText)
                    )
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 16) {
            BigButton("保存到相册") {
                _ = viewModel.saveToPhotos()
                showSaveAlert = true
            }
            .disabled(viewModel.posterImage == nil)

            BigButton("分享给朋友", style: .secondary) {
                showShareSheet = true
            }
            .disabled(viewModel.posterImage == nil)
        }
    }
}

// MARK: - Preview

#Preview("Poster Preview") {
    NavigationStack {
        PosterPreviewView(
            data: PosterData(
                date: Date(),
                totalDuration: "25 分钟",
                exerciseNames: ["椅子坐立", "提踵", "桥式"],
                steps: 3200,
                heartRate: 72,
                quote: "今天也是元气满满的一天！",
                totalDays: 15
            )
        )
    }
}
