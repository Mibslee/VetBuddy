import SwiftUI
import RealityKit

/// Exercise demonstration view with 3D USDZ animation support.
/// Falls back to a styled placeholder when the model file is not bundled.
struct ExerciseDemoView: View {

    let exercise: Exercise
    let fitnessLevel: FitnessLevel
    let showsStartButton: Bool
    let onStart: () -> Void

    init(
        exercise: Exercise,
        fitnessLevel: FitnessLevel,
        showsStartButton: Bool = true,
        onStart: @escaping () -> Void
    ) {
        self.exercise = exercise
        self.fitnessLevel = fitnessLevel
        self.showsStartButton = showsStartButton
        self.onStart = onStart
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                exerciseModelArea
                exerciseInfo
                ExerciseGuidancePanel(exercise: exercise)
                setsRepsInfo
                difficultyCard
                if showsStartButton {
                    startButton
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.vbCream.ignoresSafeArea())
        .toolbar(.visible, for: .navigationBar)
    }

    // MARK: - 3D Model / Placeholder

    @ViewBuilder
    private var exerciseModelArea: some View {
        ExerciseMediaView(exercise: exercise, height: 420)
    }

    // MARK: - Exercise Info

    private var exerciseInfo: some View {
        VStack(spacing: 12) {
            Text(exercise.nameCN)
                .font(VBFont.title)
                .foregroundStyle(Color.vbMainText)

            Text(exercise.nameEN)
                .vbCaption()

            Text(exercise.description)
                .vbBody()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
    }

    // MARK: - Sets x Reps

    private var setsRepsInfo: some View {
        HStack(spacing: 16) {
            statBox(
                label: "组数",
                value: "\(exercise.setsForLevel(fitnessLevel))"
            )
            statBox(
                label: "次数",
                value: "\(exercise.repsForLevel(fitnessLevel))"
            )
            statBox(
                label: "休息",
                value: "\(exercise.restForLevel(fitnessLevel))秒"
            )
        }
    }

    private func statBox(label: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(VBFont.title)
                .foregroundStyle(Color.vbAccent)
            Text(label)
                .vbCaption()
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Difficulty Modifier

    private var difficultyCard: some View {
        HStack {
            Image(systemName: "dial.medium")
                .foregroundStyle(Color.vbAccent)
            VStack(alignment: .leading, spacing: 4) {
                Text("难度说明")
                    .vbHeadline()
                Text(exercise.difficultyModifier[fitnessLevel] ?? "标准难度")
                    .vbBody()
            }
            Spacer()
        }
        .padding(16)
        .background(Color.vbCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Start Button

    private var startButton: some View {
        BigButton("开始此动作", action: onStart)
    }

}

// MARK: - USDZ Model View (RealityKit, iOS 17+)

/// UIViewRepresentable wrapper for ARView to display USDZ models in SwiftUI.
struct USDZModelView: UIViewRepresentable {
    let modelName: String

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.environment.background = .color(.clear)
        loadModel(into: arView)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    private func loadModel(into arView: ARView) {
        guard let url = Bundle.main.url(forResource: modelName, withExtension: "usdz") else { return }
        let entity = try? ModelEntity.loadModel(contentsOf: url)
        guard let model = entity else { return }
        model.scale = SIMD3(repeating: 1.0)

        let anchor = AnchorEntity(plane: .horizontal)
        anchor.addChild(model)
        arView.scene.addAnchor(anchor)

        // Auto-play first animation if available
        if let animation = model.availableAnimations.first {
            model.playAnimation(animation.repeat(), transitionDuration: 0.3, startsPaused: false)
        }
    }
}

// MARK: - Preview

#Preview("Exercise Demo") {
    ExerciseDemoView(
        exercise: ExerciseLibrary.shared.allExercises[0],
        fitnessLevel: .L1,
        onStart: {}
    )
}
