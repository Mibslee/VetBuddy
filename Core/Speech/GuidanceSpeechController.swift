import AVFoundation
import Foundation

@MainActor
final class GuidanceSpeechController: NSObject, ObservableObject {
    @Published private(set) var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func toggle(text: String, voiceAssetName: String? = nil, loops: Bool = false) {
        guard UserAppSettings.soundEnabled else { return }
        if synthesizer.isSpeaking || audioPlayer?.isPlaying == true {
            stop()
        } else {
            speak(text, voiceAssetName: voiceAssetName, loops: loops)
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        audioPlayer?.stop()
        audioPlayer = nil
        isSpeaking = false
    }

    private func speak(_ text: String, voiceAssetName: String?, loops: Bool) {
        configureAudioSession()

        if let voiceAssetName, playVoiceAsset(named: voiceAssetName, loops: loops) {
            return
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = Float(UserAppSettings.speechRate)
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        isSpeaking = true
        synthesizer.speak(utterance)
    }

    private func playVoiceAsset(named name: String, loops: Bool) -> Bool {
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a")
            ?? Bundle.main.url(forResource: name, withExtension: "mp3")
            ?? Bundle.main.url(forResource: name, withExtension: "wav") else {
            return false
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.numberOfLoops = loops ? -1 : 0
            player.prepareToPlay()
            guard player.play() else {
                audioPlayer = nil
                isSpeaking = false
                return false
            }
            audioPlayer = player
            isSpeaking = true
            return true
        } catch {
            audioPlayer = nil
            isSpeaking = false
            return false
        }
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            // Speech remains best-effort; system TTS can still work if session setup fails.
        }
    }
}

extension GuidanceSpeechController: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
        }
    }
}

extension GuidanceSpeechController: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            if audioPlayer === player {
                audioPlayer = nil
            }
            isSpeaking = false
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            if audioPlayer === player {
                audioPlayer = nil
            }
            isSpeaking = false
        }
    }
}
