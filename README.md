# BodyTune — tvOS App (README)

Small README / developer note for the tvOS SwiftUI app you provided. This covers project purpose, structure, how to run, important implementation notes, and quick pointers for modification and debugging.

---

## Quick summary

**BodyTune** is a tvOS SwiftUI app for running group workout sessions (select athletes, choose a workout, countdown, run the session, view results). The core app entry and models live in `workout_squad_app-4.swift` and the UI screens are in the other Swift files you uploaded. See main app + models: `workout_squad_app-4.swift`. 

---

## Files you uploaded (local paths)

You can use these local paths/URLs for the files in the environment:

* `/mnt/data/workout_squad_app-4.swift` — App entry, models, `AppState`, `WorkoutSession`. 
* `/mnt/data/content_view-4.swift` — `ContentView` + `HomeView` (root view handling screen navigation). 
* `/mnt/data/athlete_selection_view-5.swift` — Athlete selection UI + add-athlete sheet. 
* `/mnt/data/workout_selection_view-5.swift` — Workout selection UI + workout cards. 
* `/mnt/data/countdown_view-3.swift` — Pre-workout countdown and squad preview. 
* `/mnt/data/active_workout_view-4.swift` — Active workout screen (timers, pause/quitting, progress). 
* `/mnt/data/results_view-4.swift` — Results and squad performance screen. 
* `/mnt/data/MADD tvOS-Bridging-Header.h` — Bridging header placeholder (empty). 

---

## How to open & run (Xcode / tvOS)

1. Open Xcode and create a new **tvOS** App (SwiftUI) project or update your existing target to tvOS.
2. Add all `.swift` source files above to the tvOS target. Verify these files are part of the tvOS target membership in File Inspector. (Use the paths above if you need to import them directly into the Xcode project).  
3. If you rely on the bridging header for any Objective-C/C headers, add `MADD tvOS-Bridging-Header.h` to the target and set the bridging header path in Build Settings if necessary (currently empty). 
4. Build & run on a tvOS simulator or a real Apple TV device. Target a recent tvOS SDK (tvOS 14+ should be fine—adjust as needed by your project settings).

---

## App flow (what each view does)

* **HomeView / ContentView** — App root and screen-switching logic. `AppState.currentScreen` drives which view is visible. 
* **AthleteSelectionView** — Add/select up to 5 athletes; launches workout selection. Includes `AddAthleteSheet`. 
* **WorkoutSelectionView** — Browse workouts and start the session. Workouts are defined in the models in the app file.  
* **CountdownView** — 3..2..1 GO! animation and squad preview; transitions to active workout. 
* **ActiveWorkoutView** — Core running state: exercise timers, rest phases, pause overlay, squad progress, and completion overlay. Timers are implemented using `Timer.scheduledTimer`. 
* **ResultsView** — Session summary, squad rankings and stats. Updates athletes’ streak/workout totals on `AppState.endWorkout()`. 

---

## Important implementation notes & tips

### State & models

* `AppState` is the single source of truth for navigation, athletes, selected workout and `WorkoutSession`. See `workout_squad_app-4.swift`. 
* `WorkoutSession` holds per-session state and `athleteProgress`. When a workout ends, `AppState.endWorkout()` updates athlete stats and switches to `.results`. 

### Timer considerations

* Active timers use `Timer.scheduledTimer` in `ActiveWorkoutView` and `CountdownView`. On tvOS you should ensure timers run on the main runloop mode used by tvOS remote events. If you see timer pauses when UI interactions happen, consider using `RunLoop.main.add(timer!, forMode: .common)` or `DispatchSourceTimer` for higher reliability.  

### Layout & tvOS focus

* UI is SwiftUI-first and sized for large screens (explicit large fonts, fixed widths). Test on multiple Apple TV resolutions. `ActiveWorkoutView` uses `GeometryReader` to scale the central circle and avoid clipping. 
* If you plan to support tvOS Focus (Siri Remote navigation), consider adding explicit `.focusable()` modifiers or adopt FocusState patterns for more complex focus flows (especially in grids of athlete/workout cards). The current UI is designed for remote interaction but doesn’t include custom focus animations.

### Accessibility

* Consider adding `accessibilityLabel` and `accessibilityHint` for critical controls (Start, Pause, Quit, Continue) and timers so visually impaired users can use VoiceOver. Also ensure dynamic type scaling where appropriate.

### Concurrency & data mutation

* `AppState` mutates athlete arrays directly. If you integrate persistence (Core Data / file-based), ensure updates are performed on correct queues and published updates are done on main thread.

---

## Quick dev checklist / debugging tips

* If a view doesn't update after state change: ensure `@Published` / `@ObservedObject` / `@EnvironmentObject` wiring is correct. `ContentView` expects `AppState` as `.environmentObject(appState)`.  
* If timers stop while the app is active: try `RunLoop.main.add(timer, forMode: .common)` or use GCD `DispatchSourceTimer`. 
* If layouts clip on smaller tvOS screens: increase use of `GeometryReader` or reduce fixed widths. `ActiveWorkoutView` already injects a `circleDiameter` to scale content. 
* To add workouts, update `Workout.predefined` in `workout_squad_app-4.swift`. 

---

## Suggested improvements / next steps

* Persist athletes and session history (UserDefaults, files, or Core Data).
* Add haptic/sound cues via tvOS-supported audio when intervals change.
* Add remote-focused keyboard input (for name entry) or a custom on-screen keyboard for tvOS.
* Add unit tests for `WorkoutSession.moveToNextPhase()` edge cases (round wrap, completion).

---

## Licensing & attribution

* This is a small internal/demo project; add a LICENSE file to your repo if you plan to share publicly.

---

If you want, I can:

* Produce a `README.md` file formatted and ready to drop in the repo (I can include the file content here).
* Produce a minimal `Package.swift` or Xcode project settings snippet (entitlements / Info.plist keys) for tvOS.
* Convert these local paths into downloadable links or zip them together (I can prepare a zip content listing).

Tell me which of those you'd like and I'll generate it right away (I already see the files you uploaded and can include them).
