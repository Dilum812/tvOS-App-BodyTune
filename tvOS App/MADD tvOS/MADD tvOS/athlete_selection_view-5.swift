import SwiftUI

struct AthleteSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedAthletes: Set<UUID> = []
    @State private var showAddAthlete = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case nameInput
    }
    
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
                                appState.currentScreen = .home
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
                    
                    Text("SELECT YOUR SQUAD")
                        .font(.system(size: 58, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Choose 2-5 family members")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 40)
                
                // Athletes grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 40),
                        GridItem(.flexible(), spacing: 40),
                        GridItem(.flexible(), spacing: 40)
                    ], spacing: 40) {
                        // Add New Athlete Card
                        AddAthleteCard {
                            withAnimation {
                                showAddAthlete = true
                            }
                        }
                        
                        // Existing Athletes
                        ForEach(appState.athletes) { athlete in
                            AthleteCardView(
                                athlete: athlete,
                                isSelected: selectedAthletes.contains(athlete.id)
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    toggleAthlete(athlete.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 80)
                    .padding(.vertical, 30)
                }
                
                // Bottom section
                VStack(spacing: 30) {
                    // Selection indicator
                    HStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(selectedAthletes.count >= 2 ? .bodyTuneSecondary : .white.opacity(0.3))
                        
                        Text("\(selectedAthletes.count) / 5 Athletes Selected")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 45)
                    .padding(.vertical, 22)
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .fill(Color.bodyTuneCard)
                    )
                    
                    // Continue button
                    Button(action: {
                        let selected = appState.athletes.filter { selectedAthletes.contains($0.id) }
                        appState.selectedAthletes = selected
                        withAnimation {
                            appState.currentScreen = .workoutSelection
                        }
                    }) {
                        HStack(spacing: 18) {
                            Text("CONTINUE")
                                .font(.system(size: 34, weight: .bold))
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 34))
                        }
                        .foregroundColor(.white)
                        .frame(width: 480, height: 85)
                        .background(
                            RoundedRectangle(cornerRadius: 45)
                                .fill(selectedAthletes.count >= 2 ? Color.bodyTunePrimary : Color.gray)
                        )
                        .shadow(color: selectedAthletes.count >= 2 ? .bodyTunePrimary.opacity(0.5) : .clear, radius: 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(selectedAthletes.count < 2)
                }
                .padding(.bottom, 60)
            }
            .blur(radius: showAddAthlete ? 10 : 0)
            
            // Add Athlete Sheet
            if showAddAthlete {
                AddAthleteSheet(
                    isPresented: $showAddAthlete,
                    focusedField: $focusedField
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    func toggleAthlete(_ id: UUID) {
        if selectedAthletes.contains(id) {
            selectedAthletes.remove(id)
        } else if selectedAthletes.count < 5 {
            selectedAthletes.insert(id)
        }
    }
}

struct AddAthleteCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 4, dash: [10]))
                        .foregroundColor(.bodyTunePrimary)
                        .frame(width: 130, height: 130)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.bodyTunePrimary)
                }
                
                Text("Add Athlete")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Create new member")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .frame(width: 300, height: 360)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [10]))
                    .foregroundColor(.bodyTunePrimary.opacity(0.5))
            )
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.bodyTuneCard.opacity(0.5))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AthleteCardView: View {
    let athlete: Athlete
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 22) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? athlete.color.opacity(0.25) : Color.bodyTuneCard)
                        .frame(width: 130, height: 130)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isSelected ? athlete.color : Color.white.opacity(0.15),
                                    lineWidth: 4
                                )
                        )
                    
                    Image(systemName: athlete.icon)
                        .font(.system(size: 56))
                        .foregroundColor(isSelected ? athlete.color : .white.opacity(0.5))
                    
                    if isSelected {
                        Circle()
                            .fill(athlete.color)
                            .frame(width: 46, height: 46)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 48, y: -48)
                    }
                }
                
                // Name
                Text(athlete.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                // Stats
                VStack(spacing: 10) {
                    StatRowCompact(icon: "flame.fill", value: "\(athlete.streak)", label: "streak", color: .orange)
                    StatRowCompact(icon: "dumbbell.fill", value: "\(athlete.totalWorkouts)", label: "workouts", color: .bodyTuneSecondary)
                    StatRowCompact(icon: "clock.fill", value: "\(athlete.totalMinutes)", label: "min", color: .bodyTunePrimary)
                }
            }
            .frame(width: 300, height: 360)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.bodyTuneCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(
                                isSelected ? athlete.color.opacity(0.6) : Color.clear,
                                lineWidth: 3
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(color: isSelected ? athlete.color.opacity(0.4) : .clear, radius: 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatRowCompact: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 26)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

struct AddAthleteSheet: View {
    @EnvironmentObject var appState: AppState
    @Binding var isPresented: Bool
    @FocusState.Binding var focusedField: AthleteSelectionView.Field?
    @State private var name: String = ""
    @State private var selectedIcon: String = "figure.stand"
    @State private var selectedColor: Color = .bodyTunePrimary
    
    let icons = ["figure.stand", "figure.stand.dress", "figure.wave", "figure.dance", "figure.walk", "figure.run", "figure.child"]
    let colors: [Color] = [.bodyTunePrimary, .bodyTuneSecondary, .purple, .orange, .pink, .cyan, .yellow, .red]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.90)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Close button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 40)
                
                Text("ADD NEW ATHLETE")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                // Preview
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(selectedColor.opacity(0.25))
                            .frame(width: 140, height: 140)
                        
                        Image(systemName: selectedIcon)
                            .font(.system(size: 60))
                            .foregroundColor(selectedColor)
                    }
                    
                    Text(name.isEmpty ? "Name" : name)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 25)
                .frame(width: 650)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.bodyTuneCard)
                )
                
                // Name input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Name")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack {
                        TextField("Enter name", text: $name)
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .focused($focusedField, equals: .nameInput)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.bodyTuneBackground)
                            )
                    }
                }
                .frame(width: 650)
                
                // Icon selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose Icon")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 20) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: {
                                withAnimation {
                                    selectedIcon = icon
                                }
                            }) {
                                Image(systemName: icon)
                                    .font(.system(size: 36))
                                    .foregroundColor(selectedIcon == icon ? selectedColor : .white.opacity(0.5))
                                    .frame(width: 70, height: 70)
                                    .background(
                                        Circle()
                                            .fill(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.bodyTuneCard)
                                    )
                                    .overlay(
                                        Circle()
                                            .strokeBorder(selectedIcon == icon ? selectedColor : Color.clear, lineWidth: 3)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .frame(width: 650)
                
                // Color selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose Color")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 20) {
                        ForEach(colors, id: \.self) { color in
                            Button(action: {
                                withAnimation {
                                    selectedColor = color
                                }
                            }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 55, height: 55)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.white, lineWidth: selectedColor == color ? 4 : 0)
                                    )
                                    .scaleEffect(selectedColor == color ? 1.1 : 1.0)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .frame(width: 650)
                
                // Buttons
                HStack(spacing: 25) {
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Text("CANCEL")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 290, height: 75)
                            .background(
                                RoundedRectangle(cornerRadius: 40)
                                    .fill(Color.bodyTuneCard)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        if !name.isEmpty {
                            appState.addNewAthlete(name: name, icon: selectedIcon, color: selectedColor)
                            withAnimation {
                                isPresented = false
                            }
                        }
                    }) {
                        Text("ADD ATHLETE")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 290, height: 75)
                            .background(
                                RoundedRectangle(cornerRadius: 40)
                                    .fill(name.isEmpty ? Color.gray : Color.bodyTunePrimary)
                            )
                            .shadow(color: name.isEmpty ? .clear : .bodyTunePrimary.opacity(0.5), radius: 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(name.isEmpty)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 40)
            .background(
                RoundedRectangle(cornerRadius: 35)
                    .fill(Color.bodyTuneBackground.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 35)
                            .strokeBorder(Color.bodyTunePrimary.opacity(0.5), lineWidth: 3)
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 50)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .nameInput
            }
        }
    }
}
