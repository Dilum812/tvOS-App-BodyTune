import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var session: WorkoutSession
    @State private var showStats = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 30) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.bodyTuneSecondary)
                
                Text("SESSION COMPLETE")
                    .font(.system(size: 68, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text(session.workout.name)
                    .font(.system(size: 38, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.top, 70)
            .padding(.bottom, 50)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showStats = true
                    }
                }
            }
            
            // Summary cards
                if showStats {
                HStack(spacing: 35) {
                    SummaryStatCard(icon: "clock.fill", value: "\(session.totalElapsedTime / 60)", unit: "min", label: "Duration", color: .bodyTunePrimary)
                    SummaryStatCard(icon: "arrow.triangle.2.circlepath", value: "\(session.workout.totalRounds)", unit: "rounds", label: "Completed", color: .bodyTuneSecondary)
                    SummaryStatCard(icon: "dumbbell.fill", value: "\(session.workout.exercises.count * session.workout.totalRounds)", unit: "exercises", label: "Total", color: .purple)
                    SummaryStatCard(icon: "flame.fill", value: "\(session.workout.calories)", unit: "kcal", label: "Burned", color: .orange)
                }
                .padding(.horizontal, 80)
                .padding(.bottom, 40)
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.horizontal, 100)
            
            // Squad performance title
            if showStats {
                Text("SQUAD PERFORMANCE")
                    .font(.system(size: 46, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 40)
            }
            
            // Athlete results
            ScrollView {
                VStack(spacing: 30) {
                    ForEach(Array(session.athletes.enumerated()), id: \.element.id) { index, athlete in
                        if let progress = session.athleteProgress[athlete.id] {
                            AthleteResultCardView(
                                athlete: athlete,
                                progress: progress,
                                totalRounds: session.workout.totalRounds,
                                rank: index + 1
                            )
                            .opacity(showStats ? 1 : 0)
                            .offset(x: showStats ? 0 : -50)
                        }
                    }
                }
                .padding(.horizontal, 80)
            }
            
            // Action buttons
            HStack(spacing: 40) {
                Button(action: {
                    withAnimation {
                        appState.currentScreen = .workoutSelection
                    }
                }) {
                    HStack(spacing: 18) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 32))
                        Text("NEW WORKOUT")
                            .font(.system(size: 34, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 420, height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .fill(Color.bodyTuneCard)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    withAnimation {
                        appState.resetToHome()
                    }
                }) {
                    HStack(spacing: 18) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 32))
                        Text("HOME")
                            .font(.system(size: 34, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 340, height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .fill(Color.bodyTunePrimary)
                    )
                    .shadow(color: .bodyTunePrimary.opacity(0.5), radius: 20)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 70)
        }
        .background(Color.bodyTuneBackground)
    }
}

struct SummaryStatCard: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(color)
            
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(value)
                    .font(.system(size: 52, weight: .black))
                    .foregroundColor(.white)
                
                Text(unit)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text(label)
                .font(.system(size: 22))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.bodyTuneCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .strokeBorder(color.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

struct AthleteResultCardView: View {
    let athlete: Athlete
    let progress: WorkoutSession.AthleteProgress
    let totalRounds: Int
    let rank: Int
    @State private var progressAnimation: CGFloat = 0
    
    var completionPercentage: Int {
        guard totalRounds > 0 else { return 0 }
        return Int((Double(progress.completedRounds) / Double(totalRounds)) * 100)
    }
    
    var performanceText: String {
        switch completionPercentage {
        case 100: return "Perfect!"
        case 75..<100: return "Great Job!"
        case 50..<75: return "Good Effort!"
        default: return "Completed"
        }
    }
    
    var rankIcon: String {
        switch rank {
        case 1: return "1.circle.fill"
        case 2: return "2.circle.fill"
        case 3: return "3.circle.fill"
        default: return "star.circle.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 40) {
            // Rank
            Image(systemName: rankIcon)
                .font(.system(size: 70))
                .foregroundColor(rank <= 3 ? .bodyTuneSecondary : .white.opacity(0.5))
            
            // Avatar
            ZStack {
                Circle()
                    .fill(athlete.color.opacity(0.2))
                    .frame(width: 130, height: 130)
                
                Image(systemName: athlete.icon)
                    .font(.system(size: 60))
                    .foregroundColor(athlete.color)
            }
            
            // Stats
            VStack(alignment: .leading, spacing: 20) {
                Text(athlete.name)
                    .font(.system(size: 38, weight: .black))
                    .foregroundColor(.white)
                
                HStack(spacing: 60) {
                    ResultStat(icon: "arrow.triangle.2.circlepath", label: "Rounds", value: "\(progress.completedRounds)/\(totalRounds)")
                    ResultStat(icon: "chart.bar.fill", label: "Completion", value: "\(completionPercentage)%")
                    ResultStat(icon: "star.fill", label: "Rating", value: performanceText)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 24)
                        
                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                LinearGradient(
                                    colors: [athlete.color, athlete.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progressAnimation, height: 24)
                    }
                }
                .frame(height: 24)
                .onAppear {
                    withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.3)) {
                        progressAnimation = CGFloat(completionPercentage) / 100
                    }
                }
            }
            
            Spacer()
            
            // Streak
            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 110, height: 110)
                    
                    VStack(spacing: 5) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        
                        Text("\(athlete.streak + 1)")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.white)
                    }
                }
                
                Text("Day Streak")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.bodyTuneCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .strokeBorder(athlete.color.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

struct ResultStat: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.bodyTuneSecondary)
                
                Text(label)
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
