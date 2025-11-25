import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            
            Color.bodyTuneBackground
                .ignoresSafeArea()
            
            Group {
                switch appState.currentScreen {
                case .home:
                    HomeView()
                        .transition(.opacity)
                case .athleteSelection:
                    AthleteSelectionView()
                        .transition(.opacity)
                case .workoutSelection:
                    WorkoutSelectionView()
                        .transition(.opacity)
                case .countdown:
                    if let session = appState.sessionInProgress {
                        CountdownView(session: session)
                            .transition(.opacity)
                    }
                case .activeWorkout:
                    if let session = appState.sessionInProgress {
                        ActiveWorkoutView(session: session)
                            .transition(.opacity)
                    }
                case .results:
                    if let session = appState.sessionInProgress {
                        ResultsView(session: session)
                            .transition(.opacity)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.currentScreen)
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var logoScale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo section
            VStack(spacing: 40) {
                // BodyTune Logo
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .scaleEffect(logoScale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            logoScale = 1.0
                        }
                    }
                
                VStack(spacing: 20) {
                    Text("BODYTUNE")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(2)
                    
                    Text("Group Fitness Sessions")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Start button
            Button(action: {
                withAnimation {
                    appState.currentScreen = .athleteSelection
                }
            }) {
                HStack(spacing: 20) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 40, weight: .semibold))
                    
                    Text("START SESSION")
                        .font(.system(size: 38, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(width: 600, height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.bodyTunePrimary)
                )
                .cornerRadius(50)
                .shadow(color: .bodyTunePrimary.opacity(0.6), radius: 25, x: 0, y: 10)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Stats footer
            HStack(spacing: 120) {
                StatItem(icon: "person.3.fill", value: "\(appState.athletes.count)", label: "Athletes")
                StatItem(icon: "dumbbell.fill", value: "\(Workout.predefined.count)", label: "Workouts")
                StatItem(icon: "chart.bar.fill", value: "0", label: "Sessions")
            }
            .padding(.bottom, 80)
        }
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundColor(.bodyTuneSecondary)
            
            Text(value)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}
