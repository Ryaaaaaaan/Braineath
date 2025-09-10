//
//  EmergencyFollowUpView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI

struct EmergencyFollowUpView: View {
    @ObservedObject var viewModel: EmergencyViewModel
    let onComplete: () -> Void
    @State private var distressAfter: Int = 5
    @State private var notes: String = ""
    @State private var helpfulTechniques: [String] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Message de félicitations
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Bien joué !")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Vous avez pris soin de vous dans un moment difficile. C'est un acte de courage.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Évaluation après
                    VStack(spacing: 16) {
                        Text("Comment vous sentez-vous maintenant ?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Niveau de détresse:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(distressAfter)/10")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(colorForDistress(distressAfter))
                            }
                            
                            Slider(
                                value: Binding(
                                    get: { Double(distressAfter) },
                                    set: { distressAfter = Int($0) }
                                ),
                                in: 1...10,
                                step: 1
                            ) {
                                Text("Niveau après")
                            }
                            .accentColor(colorForDistress(distressAfter))
                            
                            HStack {
                                Text("Beaucoup mieux")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Toujours difficile")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Techniques les plus utiles
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quelles techniques vous ont aidé ?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(EmergencyTechnique.allTechniques, id: \.id) { technique in
                                TechniqueRatingCard(
                                    technique: technique,
                                    isSelected: helpfulTechniques.contains(technique.name)
                                ) {
                                    if helpfulTechniques.contains(technique.name) {
                                        helpfulTechniques.removeAll { $0 == technique.name }
                                    } else {
                                        helpfulTechniques.append(technique.name)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Notes personnelles
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Réflexions (optionnel)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Suggestions de suivi
                    suggestionsSection
                    
                    // Bouton de sauvegarde
                    Button("Terminer le suivi") {
                        saveFollowUp()
                        onComplete()
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.green, .blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .navigationTitle("Suivi")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Prochaines étapes recommandées")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                SuggestionCard(
                    title: "Planifier une session de respiration",
                    subtitle: "Dans les prochaines heures",
                    icon: "lungs.fill",
                    color: .blue
                )
                
                SuggestionCard(
                    title: "Noter vos pensées",
                    subtitle: "Journalisation émotionnelle",
                    icon: "square.and.pencil",
                    color: .purple
                )
                
                SuggestionCard(
                    title: "Contacter un proche",
                    subtitle: "Partager ce que vous ressentez",
                    icon: "message.fill",
                    color: .green
                )
                
                if distressAfter > 6 {
                    SuggestionCard(
                        title: "Considérer une aide professionnelle",
                        subtitle: "Si les difficultés persistent",
                        icon: "cross.case.fill",
                        color: .red
                    )
                }
            }
        }
    }
    
    private func saveFollowUp() {
        viewModel.updateDistressAfter(distressAfter)
        
        if let session = viewModel.currentSession {
            session.notes = notes.isEmpty ? nil : notes
            
            // Ajouter les techniques utiles aux notes
            if !helpfulTechniques.isEmpty {
                let techniquesNote = "Techniques utiles: " + helpfulTechniques.joined(separator: ", ")
                session.notes = session.notes?.isEmpty ?? true ? techniquesNote : (session.notes! + "\n" + techniquesNote)
            }
        }
        
        // Feedback haptique
        AudioManager.shared.playNotificationHaptic(type: .success)
    }
    
    private func colorForDistress(_ level: Int) -> Color {
        switch level {
        case 1...3:
            return .green
        case 4...6:
            return .orange
        default:
            return .red
        }
    }
}

struct TechniqueRatingCard: View {
    let technique: EmergencyTechnique
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: technique.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? technique.color : .secondary)
                
                Text(technique.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(technique.color)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? technique.color.opacity(0.1) : Color(.tertiarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? technique.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SuggestionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
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
            
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    let viewModel = EmergencyViewModel()
    return EmergencyFollowUpView(viewModel: viewModel) {
        print("Suivi terminé")
    }
}