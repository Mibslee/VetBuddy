# Voice Assets

`Resources/Voice/Generated` is intentionally kept out of git except for `.gitkeep`.

Local release builds can include generated voice assets with these names:

- `voice_<exercise_id>.mp3` for safety and key-point narration.
- `rhythm_<exercise_id>.mp3` for rhythm guidance during training.

The app falls back to system TTS when a generated file is missing. Do not commit personal voice samples or generated cloned voice files to the public source repository.
