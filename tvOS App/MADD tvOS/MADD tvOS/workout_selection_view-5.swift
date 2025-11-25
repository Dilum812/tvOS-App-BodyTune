import SwiftUI

struct WorkoutSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedWorkout: Workout?
    
    var body: some View {
        ZStack {
            Color.bodyTuneBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 20) {
                    HStack {
                        Button(action: {
                            withAnimation {
                                appState.currentScreen = .athleteSelection
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 28, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 28, weight: .semibold))
                            }
                            .foregroundColor(.white.opacity(0.8))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                    .padding(.horizontal, 80)
                    .padding(.top, 50)
                    
                    Text("CHOOSE WORKOUT")
                        .font(.system(size: 58, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Select your training")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 40)
                
                // Workouts grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 40),
                        GridItem(.flexible(), spacing: 40)
                    ], spacing: 40) {
                        ForEach(Workout.predefined) { workout in
                            WorkoutCardView(
                                workout: workout,
                                isSelected: selectedWorkout?.id == workout.id
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedWorkout = workout
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 80)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                
                // Continue button
                Button(action: {
                    if let workout = selectedWorkout {
                        appState.startWorkout(with: appState.selectedAthletes, workout: workout)
                    }
                }) {
                    HStack(spacing: 20) {
                        Text("START WORKOUT")
                            .font(.system(size: 34, weight: .bold))
                        
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 34))
                    }
                    .foregroundColor(.white)
                    .frame(width: 480, height: 85)
                    .background(
                        RoundedRectangle(cornerRadius: 45)
                            .fill(selectedWorkout != nil ? Color.bodyTunePrimary : Color.gray)
                    )
                    .shadow(color: selectedWorkout != nil ? .bodyTunePrimary.opacity(0.5) : .clear, radius: 20)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(selectedWorkout == nil)
                .padding(.bottom, 60)
            }
        }
    }
}

struct WorkoutCardView: View {
    let workout: Workout
    let isSelected: Bool
    let action: () -> Void
    
    var difficultyColor: Color {
        switch workout.difficulty {
        case .beginner: return .bodyTuneSecondary
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Header with icon and title
                HStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(difficultyColor.opacity(0.2))
                            .frame(width: 85, height: 85)
                        
                        Image(systemName: workout.icon)
                            .font(.system(size: 40))
                            .foregroundColor(difficultyColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(workout.name)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        HStack(spacing: 10) {
                            Badge(text: workout.difficulty.rawValue, color: difficultyColor)
                            Badge(text: workout.category.rawValue, color: .bodyTunePrimary)
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 28)
                .padding(.top, 28)
                .padding(.bottom, 20)
                
                // Description
                Text(workout.description)
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 20)
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.horizontal, 28)
                
                // Stats row
                HStack(spacing: 0) {
                    WorkoutStat(icon: "clock.fill", value: "\(workout.totalDuration)", unit: "min")
                    WorkoutStat(icon: "arrow.triangle.2.circlepath", value: "\(workout.totalRounds)", unit: "rounds")
                    WorkoutStat(icon: "list.bullet", value: "\(workout.exercises.count)", unit: "ex")
                    WorkoutStat(icon: "flame.fill", value: "\(workout.calories)", unit: "cal")
                }
                .padding(.vertical, 22)
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.horizontal, 28)
                
                // Exercises preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Exercises")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    VStack(spacing: 8) {
                        ForEach(workout.exercises.prefix(3)) { exercise in
                            HStack(spacing: 12) {
                                Image(systemName: exercise.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(.bodyTuneSecondary)
                                    .frame(width: 28)
                                
                                Text(exercise.name)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                                
                                Text("\(exercise.duration)s")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.bodyTuneSecondary)
                            }
                        }
                        
                        if workout.exercises.count > 3 {
                            Text("+ \(workout.exercises.count - 3) more")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.top, 4)
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 22)
            }
            .frame(width: 600)
            .frame(minHeight: 500, maxHeight: 520)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.bodyTuneCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(
                                isSelected ? difficultyColor : Color.clear,
                                lineWidth: 3
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(color: isSelected ? difficultyColor.opacity(0.4) : .clear, radius: 25)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Badge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(color.opacity(0.3))
            )
    }
}

struct WorkoutStat: View {
    let icon: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(.bodyTuneSecondary)
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text(unit)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}
