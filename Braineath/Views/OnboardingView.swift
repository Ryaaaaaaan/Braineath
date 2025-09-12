//
//  OnboardingView.swift
//  Braineath
//
//  Created by Ryan Zemri on 12/09/2025.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var profileManager = UserProfileManager.shared
    @State private var currentStep = 0
    @State private var name = ""
    @State private var age = ""
    @State private var selectedGoals: Set<WellnessGoal> = []
    @State private var stressLevel = 5
    @State private var experienceLevel = ExperienceLevel.beginner
    @State private var selectedTimes: Set<PreferredTime> = []
    @State private var customTriggers = ""
    
    private let steps = [
        "Bienvenue",
        "Prénom",
        "Objectifs",
        "Stress",
        "Expérience",
        "Horaires",
        "Déclencheurs"
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1),
                    Color.pink.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Progress bar
                if currentStep > 0 {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Étape \(currentStep) sur \(steps.count - 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        ProgressView(value: Double(currentStep), total: Double(steps.count - 1))
                            .tint(.blue)
                    }
                    .padding(.horizontal)
                }
                
                // Content
                ScrollView {
                    VStack(spacing: 40) {
                        switch currentStep {
                        case 0: welcomeStep
                        case 1: nameStep
                        case 2: goalsStep
                        case 3: stressStep
                        case 4: experienceStep
                        case 5: timesStep
                        case 6: triggersStep
                        default: EmptyView()
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if currentStep > 0 {
                        Button("Précédent") {
                            withAnimation(.spring()) {
                                currentStep -= 1
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Button(currentStep == steps.count - 1 ? "Terminer" : "Suivant") {
                        if currentStep == steps.count - 1 {
                            completeOnboarding()
                        } else {
                            withAnimation(.spring()) {
                                currentStep += 1
                            }
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(isNextEnabled ? Color.blue : Color.gray)
                    )
                    .disabled(!isNextEnabled)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Bienvenue dans Braineath")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Nous allons personnaliser votre expérience en quelques étapes simples pour vous offrir le meilleur accompagnement possible.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            VStack(spacing: 16) {
                FeatureRow(icon: "person.fill", title: "Personnalisé", description: "Adapté à vos besoins")
                FeatureRow(icon: "lock.shield", title: "Privé", description: "Vos données restent sur votre appareil")
                FeatureRow(icon: "heart.fill", title: "Bienveillant", description: "Un accompagnement sans jugement")
            }
        }
    }
    
    private var nameStep: some View {
        VStack(spacing: 30) {
            Text("Comment souhaitez-vous être appelé(e) ?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Nous utiliserons ce prénom pour personnaliser votre expérience.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                TextField("Votre prénom", text: $name)
                    .font(.title3)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5)
                    .onChange(of: name) { newValue in
                        name = removeEmojis(from: newValue)
                    }
                
                TextField("Âge (optionnel)", text: $age)
                    .keyboardType(.numberPad)
                    .font(.body)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5)
            }
        }
    }
    
    private var goalsStep: some View {
        VStack(spacing: 30) {
            Text("Quels sont vos objectifs principaux ?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Sélectionnez jusqu'à 3 objectifs qui vous correspondent le mieux.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(WellnessGoal.allCases, id: \.self) { goal in
                    GoalSelectionCard(
                        goal: goal,
                        isSelected: selectedGoals.contains(goal)
                    ) {
                        if selectedGoals.contains(goal) {
                            selectedGoals.remove(goal)
                        } else if selectedGoals.count < 3 {
                            selectedGoals.insert(goal)
                        }
                    }
                }
            }
        }
    }
    
    private var stressStep: some View {
        VStack(spacing: 30) {
            Text("Quel est votre niveau de stress actuel ?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Sur une échelle de 1 (très détendu) à 10 (très stressé)")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                HStack {
                    Text("1")
                        .font(.caption)
                        .foregroundColor(.green)
                    Spacer()
                    Text("5")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Spacer()
                    Text("10")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Slider(value: Binding(
                    get: { Double(stressLevel) },
                    set: { stressLevel = Int($0.rounded()) }
                ), in: 1...10, step: 1)
                
                Text("\(stressLevel)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(colorForStressLevel(stressLevel))
            }
        }
    }
    
    private var experienceStep: some View {
        VStack(spacing: 30) {
            Text("Votre expérience avec les techniques de bien-être")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                ForEach(ExperienceLevel.allCases, id: \.self) { level in
                    Button(action: { experienceLevel = level }) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(level.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                if experienceLevel == level {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Text(level.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(experienceLevel == level ? Color.blue.opacity(0.1) : Color(.systemBackground))
                                .stroke(experienceLevel == level ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var timesStep: some View {
        VStack(spacing: 30) {
            Text("Quand préférez-vous pratiquer ?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Sélectionnez vos moments préférés (plusieurs choix possibles)")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                ForEach(PreferredTime.allCases, id: \.self) { time in
                    Button(action: {
                        if selectedTimes.contains(time) {
                            selectedTimes.remove(time)
                        } else {
                            selectedTimes.insert(time)
                        }
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: time.icon)
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text(time.rawValue)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedTimes.contains(time) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedTimes.contains(time) ? Color.blue.opacity(0.1) : Color(.systemBackground))
                                .stroke(selectedTimes.contains(time) ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var triggersStep: some View {
        VStack(spacing: 30) {
            Text("Dernière étape !")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Y a-t-il des situations qui vous stressent particulièrement ? (optionnel)")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            TextEditor(text: $customTriggers)
                .frame(height: 120)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            
            Text("Exemples : travail, transports, relations sociales...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var isNextEnabled: Bool {
        switch currentStep {
        case 0: return true
        case 1: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 2: return !selectedGoals.isEmpty
        case 3: return true
        case 4: return true
        case 5: return !selectedTimes.isEmpty
        case 6: return true
        default: return false
        }
    }
    
    private func colorForStressLevel(_ level: Int) -> Color {
        switch level {
        case 1...3: return .green
        case 4...6: return .orange
        case 7...10: return .red
        default: return .gray
        }
    }
    
    private func completeOnboarding() {
        let triggers = customTriggers.trimmingCharacters(in: .whitespaces)
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let profile = UserProfile(
            name: name.trimmingCharacters(in: .whitespaces),
            age: Int(age),
            primaryGoals: Array(selectedGoals),
            stressLevel: stressLevel,
            experienceLevel: experienceLevel,
            preferredTimes: Array(selectedTimes),
            triggers: triggers
        )
        
        withAnimation(.spring()) {
            profileManager.saveProfile(profile)
        }
    }
    
    private func removeEmojis(from text: String) -> String {
        return text.unicodeScalars.filter { scalar in
            // Keep only basic Latin characters, spaces, and common diacritics
            let value = scalar.value
            return (value >= 0x0020 && value <= 0x007E) || // Basic Latin
                   (value >= 0x00A0 && value <= 0x00FF) || // Latin-1 Supplement
                   (value >= 0x0100 && value <= 0x017F) || // Latin Extended-A
                   (value >= 0x0180 && value <= 0x024F)    // Latin Extended-B
        }.map { String($0) }.joined()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct GoalSelectionCard: View {
    let goal: WellnessGoal
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: goal.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(goal.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemBackground))
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingView()
}