import SwiftUI

struct CountdownView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var session: WorkoutSession
    @State private var countdown = 3
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            Color.bodyTuneBackground
                .ignoresSafeArea()
            
            VStack(spacing: 80) {
                // Workout name
                VStack(spacing: 20) {
                    Text("Get Ready! 🏋️")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(session.workout.name)
                        .font(.system(size: 36))
                        .foregroundColor(.bodyTuneSecondary)
                }
                
                // Countdown circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 20)
                        .frame(width: 400, height: 400)
                    
                    Circle()
                        .fill(
                            Color.bodyTunePrimary
                        )
                        .frame(width: 400, height: 400)
                        .shadow(color: .bodyTunePrimary.opacity(0.6), radius: 40)
                    
                    if countdown > 0 {
                        Text("\(countdown)")
                            .font(.system(size: 200, weight: .black))
                            .foregroundColor(.white)
                            .scaleEffect(scale)
                    } else {
                        Text("GO!")
                            .font(.system(size: 100, weight: .black))
                            .foregroundColor(.white)
                            .scaleEffect(scale)
                    }
                }
                
                // Squad preview
                VStack(spacing: 25) {
                    Text("Your Squad")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(spacing: 30) {
                        ForEach(session.athletes) { athlete in
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(athlete.color.opacity(0.2))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: athlete.icon)
                                        .font(.system(size: 40))
                                        .foregroundColor(athlete.color)
                                }
                                
                                Text(athlete.name)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            startCountdown()
        }
    }
    
    func startCountdown() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scale = 1.0
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale = 1.3
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        scale = 1.0
                    }
                }
                
                countdown -= 1
            } else {
                timer.invalidate()
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1.5
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        appState.beginWorkout()
                    }
                }
            }
        }
    }
}
