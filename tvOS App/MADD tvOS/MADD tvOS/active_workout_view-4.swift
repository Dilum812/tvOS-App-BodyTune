import SwiftUI

struct ActiveWorkoutView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var session: WorkoutSession
    @State private var timer: Timer?
    @State private var isPaused = false

    var body: some View {
        GeometryReader { geometry in // --- NEW: top-level geometry reader to compute available size
            ZStack {
                Color.bodyTuneBackground
                    .ignoresSafeArea()

                if session.isCompleted {
                    WorkoutCompletedOverlay {
                        appState.endWorkout()
                    }
                } else {
                    VStack(spacing: 0) {
                        // Top bar
                        WorkoutTopBar(
                            session: session,
                            isPaused: isPaused,
                            onPause: {
                                isPaused.toggle()
                                if isPaused {
                                    stopTimer()
                                } else {
                                    startTimer()
                                }
                            },
                            onQuit: {
                                stopTimer()
                                appState.resetToHome()
                            }
                        )
                        .frame(maxWidth: .infinity) // --- NEW: prevent top bar from forcing layout weirdness
                        .padding(.top, geometry.safeAreaInsets.top) // --- NEW: respect top safe area

                        Spacer()

                        // Main content (scaled)
                        Group {
                            if session.isResting {
                                RestContentView(session: session,
                                                circleDiameter: min(geometry.size.width * 0.6, geometry.size.height * 0.45)) // --- NEW
                            } else {
                                ExerciseContentView(session: session,
                                                    circleDiameter: min(geometry.size.width * 0.6, geometry.size.height * 0.5)) // --- NEW
                            }
                        }
                        .frame(maxWidth: .infinity) // --- NEW: allow central content to center itself

                        Spacer(minLength: 20) // --- NEW: small spacer to avoid clipping

                        // Bottom squad progress - respect safe area so it doesn't get cropped
                        SquadProgressView(session: session)
                            .padding(.bottom, geometry.safeAreaInsets.bottom + 34) // --- NEW: add safe-area aware bottom padding
                    }
                    .padding(.horizontal, 28) // --- NEW: global horizontal padding so big elements don't overflow
                }

                if isPaused {
                    PauseOverlay(
                        isPresented: $isPaused,
                        onResume: {
                            isPaused = false
                            startTimer()
                        },
                        onQuit: {
                            stopTimer()
                            appState.resetToHome()
                        }
                    )
                }
            }
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
        } // GeometryReader end
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if session.timeRemaining > 0 {
                session.timeRemaining -= 1
                session.totalElapsedTime += 1
            } else {
                session.moveToNextPhase()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// --- NEW: Top bar changes: removed internal GeometryReader and used a fixed-width progress bar to avoid layout forcing
struct WorkoutTopBar: View {
    @ObservedObject var session: WorkoutSession
    let isPaused: Bool
    let onPause: () -> Void
    let onQuit: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            // Workout name
            Text(session.workout.name)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            // Round progress
            VStack(spacing: 12) {
                HStack(spacing: 15) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 26))

                    Text("Round \(session.currentRound) / \(session.workout.totalRounds)")
                        .font(.system(size: 26, weight: .bold))
                }
                .foregroundColor(.white)

                // Replaced GeometryReader with fixed-size ZStack progress bar to avoid layout expansion.
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.bodyTuneSecondary)
                        .frame(width: 350 * CGFloat(session.progressPercentage), height: 10) // --- NEW
                }
                .frame(width: 350, height: 10)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.bodyTuneCard)
            )

            Spacer()

            // Controls
            HStack(spacing: 25) {
                Button(action: onPause) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .frame(width: 75, height: 75)
                        .background(
                            Circle()
                                .fill(Color.bodyTuneAccent)
                        )
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: onQuit) {
                    Image(systemName: "xmark")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .frame(width: 75, height: 75)
                        .background(
                            Circle()
                                .fill(Color.red)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 20)
    }
}

// --- NEW: ExerciseContentView now accepts a circleDiameter so it scales to available space
struct ExerciseContentView: View {
    @ObservedObject var session: WorkoutSession
    let circleDiameter: CGFloat // --- NEW: injected diameter

    var body: some View {
        VStack(spacing: 36) {
            // Exercise icon - scaleable so it doesn't get cropped
            Image(systemName: session.currentExercise.icon)
                .font(.system(size: min(circleDiameter * 0.25, 120))) // --- NEW: scale with circle size
                .foregroundColor(.bodyTuneSecondary)
                .padding(.top, 6) // --- NEW: small padding so icon doesn't touch top

            // Exercise name
            Text(session.currentExercise.name.uppercased())
                .font(.system(size: min(circleDiameter * 0.16, 72), weight: .black, design: .rounded)) // --- NEW: dynamic font sizing
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // Timer - uses injected circleDiameter instead of fixed 450
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: circleDiameter * 0.055)
                    .frame(width: circleDiameter, height: circleDiameter)

                Circle()
                    .trim(from: 0, to: CGFloat(session.timeRemaining) / CGFloat(max(1, session.currentExercise.duration)))
                    .stroke(
                        Color.bodyTuneSecondary,
                        style: StrokeStyle(lineWidth: circleDiameter * 0.055, lineCap: .round)
                    )
                    .frame(width: circleDiameter, height: circleDiameter)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 8) {
                    Text("\(session.timeRemaining)")
                        .font(.system(size: min(circleDiameter * 0.3, 150), weight: .black)) // --- NEW: dynamic size
                        .foregroundColor(.white)

                    Text("SECONDS")
                        .font(.system(size: min(circleDiameter * 0.06, 30), weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            // Motivation text
            Text(getMotivationText(for: session.timeRemaining))
                .font(.system(size: min(circleDiameter * 0.08, 38), weight: .bold)) // --- NEW: dynamic
                .foregroundColor(.bodyTuneSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    func getMotivationText(for time: Int) -> String {
        switch time {
        case 20...30: return "PUSH HARDER!"
        case 10...19: return "KEEP GOING!"
        case 5...9: return "ALMOST THERE!"
        case 1...4: return "FINISH STRONG!"
        default: return "YOU GOT THIS!"
        }
    }
}

// --- NEW: RestContentView also accepts circleDiameter and scales its internals
struct RestContentView: View {
    @ObservedObject var session: WorkoutSession
    let circleDiameter: CGFloat // --- NEW

    var body: some View {
        VStack(spacing: 36) {
            // Rest icon
            Image(systemName: "heart.fill")
                .font(.system(size: min(circleDiameter * 0.25, 120)))
                .foregroundColor(.orange)
                .padding(.top, 6)

            Text("REST TIME")
                .font(.system(size: min(circleDiameter * 0.16, 72), weight: .black, design: .rounded))
                .foregroundColor(.orange)

            // Timer (scaled)
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: circleDiameter * 0.055)
                    .frame(width: circleDiameter * 0.9, height: circleDiameter * 0.9)

                Circle()
                    .trim(from: 0, to: CGFloat(session.timeRemaining) / CGFloat(max(1, session.currentExercise.rest)))
                    .stroke(
                        Color.orange,
                        style: StrokeStyle(lineWidth: circleDiameter * 0.055, lineCap: .round)
                    )
                    .frame(width: circleDiameter * 0.9, height: circleDiameter * 0.9)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 8) {
                    Text("\(session.timeRemaining)")
                        .font(.system(size: min(circleDiameter * 0.27, 140), weight: .black))
                        .foregroundColor(.white)

                    Text("BREATHE")
                        .font(.system(size: min(circleDiameter * 0.06, 30), weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            // Next exercise
            if session.currentExerciseIndex + 1 < session.workout.exercises.count {
                VStack(spacing: 20) {
                    Text("NEXT UP")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))

                    HStack(spacing: 20) {
                        Image(systemName: session.workout.exercises[session.currentExerciseIndex + 1].icon)
                            .font(.system(size: 44))
                            .foregroundColor(.bodyTuneSecondary)

                        Text(session.workout.exercises[session.currentExerciseIndex + 1].name)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.bodyTuneCard)
                )
            }
        }
    }
}

// other views remain mostly same; no structural changes needed except maybe small layout tweaks to avoid clipping

struct SquadProgressView: View {
    @ObservedObject var session: WorkoutSession

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) { // --- NEW: make it scrollable when there are many members
            HStack(spacing: 30) {
                ForEach(session.athletes) { athlete in
                    if let progress = session.athleteProgress[athlete.id] {
                        SquadMemberCard(
                            athlete: athlete,
                            progress: progress,
                            totalRounds: session.workout.totalRounds
                        )
                        .frame(minWidth: 220) // --- NEW: give each card a minimum width so it lays out nicely
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

struct SquadMemberCard: View {
    let athlete: Athlete
    let progress: WorkoutSession.AthleteProgress
    let totalRounds: Int

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(progress.isActive ? athlete.color.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: athlete.icon)
                    .font(.system(size: 50))
                    .foregroundColor(progress.isActive ? athlete.color : .gray)
            }

            Text(athlete.name)
                .font(.system(size: 20, weight: .bold)) // --- NEW: slightly smaller to fit tvOS better
                .foregroundColor(.white)

            HStack(spacing: 8) {
                ForEach(0..<totalRounds, id: \.self) { index in
                    Circle()
                        .fill(index < progress.completedRounds ? athlete.color : Color.white.opacity(0.2))
                        .frame(width: 14, height: 14)
                }
            }

            Text("\(progress.completedRounds) / \(totalRounds)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.bodyTuneCard)
        )
    }
}

// PauseOverlay and WorkoutCompletedOverlay unchanged, but ensure they are full-screen so they don't clip content
// (kept as-is from original code)

struct PauseOverlay: View {
    @Binding var isPresented: Bool
    let onResume: () -> Void
    let onQuit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 60) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 120))
                    .foregroundColor(.bodyTuneSecondary)

                Text("PAUSED")
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                VStack(spacing: 30) {
                    Button(action: {
                        isPresented = false
                        onResume()
                    }) {
                        HStack(spacing: 20) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 36))
                            Text("RESUME")
                                .font(.system(size: 38, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(width: 520, height: 110)
                        .background(
                            RoundedRectangle(cornerRadius: 55)
                                .fill(Color.bodyTunePrimary)
                        )
                        .shadow(color: .bodyTunePrimary.opacity(0.5), radius: 20)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: onQuit) {
                        HStack(spacing: 20) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 36))
                            Text("END WORKOUT")
                                .font(.system(size: 38, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(width: 520, height: 110)
                        .background(Color.red)
                        .cornerRadius(55)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct WorkoutCompletedOverlay: View {
    let onFinish: () -> Void
    @State private var scale: CGFloat = 0.5

    var body: some View {
        ZStack {
            Color.bodyTuneBackground
                .ignoresSafeArea()

            VStack(spacing: 70) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 180))
                    .foregroundColor(.bodyTuneSecondary)
                    .scaleEffect(scale)

                VStack(spacing: 30) {
                    Text("WORKOUT")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))

                    Text("COMPLETE!")
                        .font(.system(size: 88, weight: .black, design: .rounded))
                        .foregroundColor(.bodyTuneSecondary)

                    Text("Amazing effort!")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }

                Button(action: onFinish) {
                    HStack(spacing: 20) {
                        Text("VIEW RESULTS")
                            .font(.system(size: 40, weight: .bold))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 40))
                    }
                    .foregroundColor(.white)
                    .frame(width: 550, height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 60)
                            .fill(Color.bodyTunePrimary)
                    )
                    .shadow(color: .bodyTunePrimary.opacity(0.5), radius: 30)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
            }
        }
    }
}

