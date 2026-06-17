import Foundation

enum UserAppSettings {
    private enum Keys {
        static let soundEnabled = "vb_sound_enabled"
        static let rhythmVoiceEnabled = "vb_rhythm_voice_enabled"
        static let safetyVoiceEnabled = "vb_safety_voice_enabled"
        static let speechRate = "vb_speech_rate"
    }

    static var soundEnabled: Bool {
        get { bool(for: Keys.soundEnabled, defaultValue: true) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.soundEnabled) }
    }

    static var rhythmVoiceEnabled: Bool {
        get { bool(for: Keys.rhythmVoiceEnabled, defaultValue: true) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.rhythmVoiceEnabled) }
    }

    static var safetyVoiceEnabled: Bool {
        get { bool(for: Keys.safetyVoiceEnabled, defaultValue: true) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.safetyVoiceEnabled) }
    }

    static var speechRate: Double {
        get {
            let value = UserDefaults.standard.double(forKey: Keys.speechRate)
            return value == 0 ? 0.43 : value
        }
        set { UserDefaults.standard.set(newValue, forKey: Keys.speechRate) }
    }

    private static func bool(for key: String, defaultValue: Bool) -> Bool {
        if UserDefaults.standard.object(forKey: key) == nil {
            return defaultValue
        }
        return UserDefaults.standard.bool(forKey: key)
    }
}
