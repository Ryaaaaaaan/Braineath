//
//  EmergencyModeView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI

struct EmergencyModeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EmergencyViewModel()
    @State private var currentTechnique: EmergencyTechnique?
    @State private var showingFollowUp = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fond apaisant
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color.blue.opacity(0.1),
                        Color.green.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if let technique = currentTechnique {
                    techniqueDetailView(technique)
                } else {
                    mainEmergencyView
                }
            }
            .navigationTitle("Mode SOS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var mainEmergencyView: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Message d'accueil réconfortant
                welcomeSection
                
                // Évaluation rapide de l'état
                quickAssessmentSection
                
                // Techniques d'urgence
                emergencyTechniquesSection
                
                // Contacts d'urgence (si configurés)
                emergencyContactsSection
                
                // Rappels positifs
                positiveRemindersSection
            }
            .padding()
        }
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink)
            
            Text("Vous n'êtes pas seul(e)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("Ce moment difficile passera. Choisissez une technique qui vous aidera à retrouver votre calme.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var quickAssessmentSection: some View {
        VStack(spacing: 16) {
            Text("Comment vous sentez-vous maintenant ?")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Intensité de votre détresse:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(viewModel.distressLevel)/10")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
                
                Slider(
                    value: Binding(
                        get: { Double(viewModel.distressLevel) },
                        set: { viewModel.distressLevel = Int($0) }
                    ),
                    in: 1...10,
                    step: 1
                ) {
                    Text("Niveau de détresse")
                }
                .accentColor(.red)
                
                HStack {
                    Text("Gérable")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Intense")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var emergencyTechniquesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Techniques de stabilisation")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(EmergencyTechnique.allTechniques, id: \.id) { technique in
                    EmergencyTechniqueCard(technique: technique) {
                        currentTechnique = technique
                        viewModel.startTechnique(technique)
                    }
                }
            }
        }
    }
    
    private var emergencyContactsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Besoin d'aide immédiate ?")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                EmergencyContactCard(
                    title: "SOS Amitié",
                    subtitle: "Écoute 24h/24",
                    phone: "09 72 39 40 50",
                    icon: "phone.fill",
                    color: .blue
                )
                
                EmergencyContactCard(
                    title: "Suicide Écoute",
                    subtitle: "24h/24 - 7j/7",
                    phone: "01 45 39 40 00",
                    icon: "heart.fill",
                    color: .red
                )
                
                EmergencyContactCard(
                    title: "3114",
                    subtitle: "Numéro national gratuit",
                    phone: "3114",
                    icon: "cross.case.fill",
                    color: .green
                )
            }
        }
    }
    
    private var positiveRemindersSection: some View {
        VStack(spacing: 16) {
            Text("Rappels bienveillants")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ForEach(viewModel.positiveReminders.indices, id: \.self) { index in
                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                            .font(.caption)
                        
                        Text(viewModel.positiveReminders[index])
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.quaternarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
    
    private func techniqueDetailView(_ technique: EmergencyTechnique) -> some View {
        VStack(spacing: 24) {
            // Titre et description
            VStack(spacing: 16) {
                Image(systemName: technique.icon)
                    .font(.system(size: 50))
                    .foregroundColor(technique.color)
                
                Text(technique.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(technique.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Contenu de la technique
            switch technique.type {
            case .breathing:
                breathingTechniqueContent
            case .grounding:
                groundingTechniqueContent
            case .mindfulness:
                mindfulnessTechniqueContent
            case .movement:
                movementTechniqueContent
            }
            
            // Boutons de contrôle
            HStack(spacing: 20) {
                Button("Retour") {
                    currentTechnique = nil
                    viewModel.completeTechnique()
                }
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 120, height: 50)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                
                Button("Terminé") {
                    viewModel.completeTechnique()
                    showingFollowUp = true
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 120, height: 50)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.green, .blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
        }
        .padding()
        .sheet(isPresented: $showingFollowUp) {
            EmergencyFollowUpView(viewModel: viewModel) {
                dismiss()
            }
        }
    }
    
    private var breathingTechniqueContent: some View {
        VStack(spacing: 24) {
            Text("Respirez avec moi")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Animation de respiration simple
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.6), .blue.opacity(0.2)]),
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180, height: 180)
                    .scaleEffect(viewModel.breathingScale)
                    .animation(
                        .easeInOut(duration: 4.0).repeatForever(autoreverses: true),
                        value: viewModel.breathingScale
                    )
                
                Text(viewModel.breathingInstruction)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Text("Suivez le rythme du cercle")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .onAppear {
            viewModel.startBreathingAnimation()
        }
    }
    
    private var groundingTechniqueContent: some View {
        VStack(spacing: 20) {
            Text("Technique 5-4-3-2-1")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 16) {
                GroundingStep(
                    number: "5",
                    instruction: "choses que vous pouvez voir",
                    color: .blue,
                    isActive: viewModel.groundingStep == 0
                )
                
                GroundingStep(
                    number: "4",
                    instruction: "choses que vous pouvez toucher",
                    color: .green,
                    isActive: viewModel.groundingStep == 1
                )
                
                GroundingStep(
                    number: "3",
                    instruction: "sons que vous pouvez entendre",
                    color: .orange,
                    isActive: viewModel.groundingStep == 2
                )
                
                GroundingStep(
                    number: "2",
                    instruction: "odeurs que vous pouvez sentir",
                    color: .purple,
                    isActive: viewModel.groundingStep == 3
                )
                
                GroundingStep(
                    number: "1",
                    instruction: "chose que vous pouvez goûter",
                    color: .pink,
                    isActive: viewModel.groundingStep == 4
                )
            }
            
            if viewModel.groundingStep < 5 {
                Button("Étape suivante") {
                    viewModel.nextGroundingStep()
                }
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
        }
        .onAppear {
            viewModel.startGroundingTechnique()
        }
    }
    
    private var mindfulnessTechniqueContent: some View {
        VStack(spacing: 24) {
            Text("Pleine conscience")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                Text(viewModel.mindfulnessGuidance)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text("Durée: \(viewModel.formatTime(viewModel.mindfulnessTimer))")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .onAppear {
            viewModel.startMindfulnessTechnique()
        }
    }
    
    private var movementTechniqueContent: some View {
        VStack(spacing: 24) {
            Text("Mouvement libérateur")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 20) {
                ForEach(viewModel.movementInstructions.indices, id: \.self) { index in
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        Text(viewModel.movementInstructions[index])
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

// Composants auxiliaires
struct EmergencyTechniqueCard: View {
    let technique: EmergencyTechnique
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: technique.icon)
                    .font(.title)
                    .foregroundColor(technique.color)
                
                Text(technique.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("\(technique.duration) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .padding()
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(technique.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmergencyContactCard: View {
    let title: String
    let subtitle: String
    let phone: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            if let url = URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: ""))") {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(phone)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                
                Image(systemName: "phone.fill")
                    .font(.caption)
                    .foregroundColor(color)
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GroundingStep: View {
    let number: String
    let instruction: String
    let color: Color
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(isActive ? color : color.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(number)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            Text(instruction)
                .font(.subheadline)
                .fontWeight(isActive ? .semibold : .regular)
                .foregroundColor(isActive ? .primary : .secondary)
            
            Spacer()
        }
        .opacity(isActive ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

#Preview {
    EmergencyModeView()
}