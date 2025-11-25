import SwiftUI
import Combine

@main
struct BodyTuneApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

// MARK: - Color Theme
extension Color {
    static let bodyTunePrimary = Color(red: 0.2, green: 0.6, blue: 1.0) // Blue #3399FF
    static let bodyTuneSecondary = Color(red: 0.4, green: 0.8, blue: 0.4) // Green accent
    static let bodyTuneBackground = Color(red: 0.05, green: 0.05, blue: 0.05)
    static let bodyTuneCard = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let bodyTuneAccent = Color(red: 0.2, green: 0.6, blue: 1.0) // Blue #3399FF
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var athletes: [Athlete] = []
    @Published var currentScreen: Screen = .home
    @Published var selectedWorkout: Workout?
    @Published var sessionInProgress: WorkoutSession?
    @Published var selectedAthletes: [Athlete] = []
    
    enum Screen {
        case home
        case athleteSelection
        case workoutSelection
        case countdown
        case activeWorkout
        case results
    }
    
    init() {
        loadSampleAthletes()
    }
    
    func loadSampleAthletes() {
        athletes = [
            Athlete(name: "Dad", icon: "figure.stand", color: .bodyTunePrimary),
            Athlete(name: "Mom", icon: "figure.stand.dress", color: .purple),
            Athlete(name: "Son", icon: "figure.wave", color: .orange),
            Athlete(name: "Daughter", icon: "figure.dance", color: .pink),
            Athlete(name: "Grandpa", icon: "figure.walk", color: .cyan)
        ]
    }
    
    func addNewAthlete(name: String, icon: String, color: Color) {
        let newAthlete = Athlete(name: name, icon: icon, color: color)
        athletes.append(newAthlete)
    }
    
    func startWorkout(with selectedAthletes: [Athlete], workout: Workout) {
        self.selectedAthletes = selectedAthletes
        sessionInProgress = WorkoutSession(athletes: selectedAthletes, workout: workout)
        currentScreen = .countdown
    }
    
    func beginWorkout() {
        currentScreen = .activeWorkout
    }
    
    func endWorkout() {
        for athlete in selectedAthletes {
            if let index = athletes.firstIndex(where: { $0.id == athlete.id }) {
                athletes[index].streak += 1
                athletes[index].totalWorkouts += 1
                athletes[index].totalMinutes += sessionInProgress?.workout.totalDuration ?? 0
            }
        }
        currentScreen = .results
    }
    
    func resetToHome() {
        sessionInProgress = nil
        selectedWorkout = nil
        selectedAthletes = []
        currentScreen = .home
    }
}

// MARK: - Models
struct Athlete: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var icon: String
    var color: Color
    var streak: Int = 0
    var totalWorkouts: Int = 0
    var totalMinutes: Int = 0
    var completedRounds: Int = 0
    
    static func == (lhs: Athlete, rhs: Athlete) -> Bool {
        lhs.id == rhs.id
    }
}

struct Workout: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var exercises: [Exercise]
    var totalRounds: Int
    var icon: String
    var difficulty: Difficulty
    var category: Category
    var calories: Int
    
    enum Difficulty: String {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
    
    enum Category: String {
        case hiit = "HIIT"
        case strength = "Strength"
        case cardio = "Cardio"
        case core = "Core"
    }
    
    var totalDuration: Int {
        let exerciseTime = exercises.reduce(0) { $0 + $1.duration + $1.rest }
        return (exerciseTime * totalRounds) / 60
    }
    
    static let predefined: [Workout] = [
        Workout(
            name: "Quick HIIT",
            description: "High-intensity interval training",
            exercises: [
                Exercise(name: "Jumping Jacks", duration: 30, rest: 15, icon: "figure.jumprope"),
                Exercise(name: "Burpees", duration: 30, rest: 15, icon: "figure.strengthtraining.traditional"),
                Exercise(name: "High Knees", duration: 30, rest: 15, icon: "figure.run"),
                Exercise(name: "Mountain Climbers", duration: 30, rest: 15, icon: "figure.climbing")
            ],
            totalRounds: 3,
            icon: "flame.fill",
            difficulty: .intermediate,
            category: .hiit,
            calories: 200
        ),
        Workout(
            name: "Core Crusher",
            description: "Targeted core exercises",
            exercises: [
                Exercise(name: "Plank", duration: 45, rest: 15, icon: "figure.core.training"),
                Exercise(name: "Crunches", duration: 30, rest: 15, icon: "figure.core.training"),
                Exercise(name: "Russian Twists", duration: 30, rest: 15, icon: "figure.flexibility"),
                Exercise(name: "Leg Raises", duration: 30, rest: 15, icon: "figure.strengthtraining.traditional")
            ],
            totalRounds: 3,
            icon: "bolt.circle.fill",
            difficulty: .intermediate,
            category: .core,
            calories: 180
        ),
        Workout(
            name: "Full Body",
            description: "Complete body strength circuit",
            exercises: [
                Exercise(name: "Squats", duration: 40, rest: 20, icon: "figure.strengthtraining.traditional"),
                Exercise(name: "Push-ups", duration: 30, rest: 15, icon: "figure.arms.open"),
                Exercise(name: "Lunges", duration: 40, rest: 20, icon: "figure.walk"),
                Exercise(name: "Plank to Push-up", duration: 30, rest: 15, icon: "figure.core.training")
            ],
            totalRounds: 4,
            icon: "figure.mixed.cardio",
            difficulty: .advanced,
            category: .strength,
            calories: 300
        ),
        Workout(
            name: "Cardio Blast",
            description: "Heart-pumping cardio",
            exercises: [
                Exercise(name: "High Knees", duration: 45, rest: 15, icon: "figure.run"),
                Exercise(name: "Butt Kicks", duration: 45, rest: 15, icon: "figure.run"),
                Exercise(name: "Jumping Jacks", duration: 45, rest: 15, icon: "figure.jumprope"),
                Exercise(name: "Burpees", duration: 30, rest: 20, icon: "figure.strengthtraining.traditional")
            ],
            totalRounds: 4,
            icon: "heart.circle.fill",
            difficulty: .intermediate,
            category: .cardio,
            calories: 280
        )
    ]
}

struct Exercise: Identifiable {
    let id = UUID()
    var name: String
    var duration: Int
    var rest: Int
    var icon: String
}

class WorkoutSession: ObservableObject {
    @Published var athletes: [Athlete]
    @Published var workout: Workout
    @Published var currentRound: Int = 1
    @Published var currentExerciseIndex: Int = 0
    @Published var isResting: Bool = false
    @Published var timeRemaining: Int = 0
    @Published var isCompleted: Bool = false
    @Published var athleteProgress: [UUID: AthleteProgress] = [:]
    @Published var totalElapsedTime: Int = 0
    
    struct AthleteProgress {
        var completedRounds: Int = 0
        var isActive: Bool = true
    }
    
    init(athletes: [Athlete], workout: Workout) {
        self.athletes = athletes
        self.workout = workout
        self.timeRemaining = workout.exercises[0].duration
        
        for athlete in athletes {
            athleteProgress[athlete.id] = AthleteProgress()
        }
    }
    
    var currentExercise: Exercise {
        workout.exercises[currentExerciseIndex]
    }
    
    var progressPercentage: Double {
        let totalExercises = workout.exercises.count * workout.totalRounds
        let completed = (currentRound - 1) * workout.exercises.count + currentExerciseIndex
        return Double(completed) / Double(totalExercises)
    }
    
    func moveToNextPhase() {
        if isResting {
            isResting = false
            currentExerciseIndex += 1
            
            if currentExerciseIndex >= workout.exercises.count {
                currentExerciseIndex = 0
                currentRound += 1
                
                for athlete in athletes {
                    if var progress = athleteProgress[athlete.id], progress.isActive {
                        progress.completedRounds += 1
                        athleteProgress[athlete.id] = progress
                    }
                }
                
                if currentRound > workout.totalRounds {
                    isCompleted = true
                    return
                }
            }
            
            timeRemaining = currentExercise.duration
        } else {
            isResting = true
            timeRemaining = currentExercise.rest
        }
    }
}
