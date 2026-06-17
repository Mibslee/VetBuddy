# Offline Care Coach Design

## Goal

Improve VetBuddy's offline experience for older users by making the app feel more direct, supportive, and responsive without adding networking, accounts, or online AI.

## Selected Direction

Use the "today coach" model. The home screen should act as a daily action center that tells the user what to do next, using only local assessment, training, nutrition, and feedback state.

## Product Principles

- Keep the app offline-first. All personalization comes from local records.
- Use warm but concrete wording. Avoid diagnosis, treatment claims, or medical certainty.
- Reduce input burden. Reuse recent meals and yesterday's meal records where possible.
- Preserve user control. Voice guidance must be adjustable and optional.
- Make training forgiving. Users can skip actions and report discomfort without feeling they failed.

## Features

### Home Daily Action Center

The home screen shows a focused action panel near the top. It chooses the most useful next step:

- If assessment is missing, prompt the user to complete health information.
- If today's training is missing, prompt the user to start training.
- If the latest training feedback says the session was too hard, recommend a lighter pace.
- If nutrition records are missing, prompt the user to record a meal.

The panel includes quick actions for starting training, recording food, and updating health information.

### Training Feedback Loop

After each training session, the completion screen records:

- Effort: easy, just right, or too hard.
- Discomfort: none, knee, back, dizzy, or other.

The data is stored locally in UserDefaults and used by later home guidance. It is not treated as medical data or sent anywhere.

### Voice Comfort Controls

Profile settings expose:

- Master voice switch.
- Training rhythm voice switch.
- Safety and notes voice switch.
- Speech rate control.

Training rhythm voice should prefer local generated assets named by exercise id. If an asset is missing, system TTS remains the fallback.

### Lower-Friction Nutrition Logging

The nutrition add sheet includes:

- Recently used foods.
- One-tap repeat of yesterday's selected meal.
- Existing common food estimates and custom entry.

Nutrition analysis remains educational only and must keep medical disclaimer language.

## Data Flow

- `TrainingCompleteView` saves local feedback through `TrainingFeedbackStore`.
- `HomeViewModel` reads latest feedback and exposes a next training hint.
- `HomeView` renders the daily action panel using assessment, training, nutrition, and feedback state.
- `NutritionViewModel` exposes recent diet entries and repeat-yesterday operations.
- `GuidanceSpeechController` respects settings from `UserAppSettings`.

## Error Handling

- If no previous feedback exists, use neutral guidance.
- If yesterday has no matching meal record, repeat action silently leaves records unchanged.
- If a local voice asset is missing, fall back to system TTS.
- If voice is disabled, guidance buttons should not start playback.

## Testing

- Build and run the app test target.
- Verify the nutrition add sheet compiles with SwiftUI `Section` syntax.
- Archive a Release build for App Store readiness.

