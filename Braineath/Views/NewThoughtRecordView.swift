//
//  NewThoughtRecordView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI

struct NewThoughtRecordView: View {
    @EnvironmentObject var viewModel: ThoughtRecordViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: CBTStep = .situation
    @State private var thoughtRecord: ThoughtRecord?
    
    // Données du formulaire
    @State private var situation = ""
    @State private var automaticThought = ""
    @State private var emotionBefore = ""
    @State private var intensityBefore = 7
    @State private var selectedDistortions: [CognitiveDistortion] = []
    @State private var balancedThought = ""
    @State private var emotionAfter = ""
    @State private var intensityAfter = 5
    @State private var actionPlan = ""
    
    enum CBTStep: Int, CaseIterable {
        case situation = 0
        case thought = 1
        case emotion = 2
        case distortions = 3
        case reframe = 4
        case outcome = 5
        case action = 6
        case complete = 7
        
        var title: String {
            switch self {
            case .situation: return "Situation"
            case .thought: return "Pensée automatique"
            case .emotion: return "Émotion ressentie"
            case .distortions: return "Distorsions cognitives"
            case .reframe: return "Reformulation"
            case .outcome: return "Nouvelle émotion"
            case .action: return "Plan d'action"
            case .complete: return "Terminé"
            }
        }
        
        var instruction: String {
            switch self {
            case .situation: return "Décrivez la situation qui a déclenché votre détresse"
            case .thought: return "Quelle pensée vous est venue automatiquement ?"
            case .emotion: return "Quelle émotion avez-vous ressentie et à quelle intensité ?"
            case .distortions: return "Identifiez les distorsions dans votre pensée"
            case .reframe: return "Reformulez votre pensée de manière plus équilibrée"
            case .outcome: return "Comment vous sentez-vous après cette reformulation ?"
            case .action: return "Que pourriez-vous faire concrètement ?"
            case .complete: return "Enregistrement terminé avec succès !"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress bar
                progressBar
                
                // Contenu principal
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        
                        switch currentStep {
                        case .situation:
                            situationStep
                        case .thought:
                            thoughtStep
                        case .emotion:
                            emotionStep
                        case .distortions:
                            distortionsStep
                        case .reframe:
                            reframeStep
                        case .outcome:
                            outcomeStep
                        case .action:
                            actionStep
                        case .complete:
                            completionStep
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
                
                // Boutons de navigation
                if currentStep != .complete {
                    navigationButtons
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        currentStep == .complete ? .green.opacity(0.1) : Color(.systemBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Button("Annuler") { dismiss() }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Étape \(currentStep.rawValue + 1) sur \(CBTStep.allCases.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            ProgressView(value: Double(currentStep.rawValue), total: Double(CBTStep.allCases.count - 1))
                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal)
        }
        .padding(.top)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile.fill")
                .font(.system(size: 50))
                .foregroundColor(.purple)
            
            Text(currentStep.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(currentStep.instruction)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var situationStep: some View {
        VStack(spacing: 16) {
            TextEditor(text: $situation)
                .frame(minHeight: 120)
                .padding()
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Exemples de situations:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("• Une conversation difficile avec un collègue")
                    Text("• Recevoir une critique sur mon travail")
                    Text("• Voir une publication sur les réseaux sociaux")
                    Text("• Une situation d'attente ou de retard")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.quaternarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var thoughtStep: some View {
        VStack(spacing: 16) {
            TextEditor(text: $automaticThought)
                .frame(minHeight: 120)
                .padding()
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Questions pour identifier vos pensées:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("• Qu'est-ce qui m'est passé par la tête ?")
                    Text("• Que me suis-je dit à moi-même ?")
                    Text("• Quelle était ma première réaction ?")
                    Text("• Qu'ai-je pensé sur moi, les autres, la situation ?")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.quaternarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var emotionStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                HStack {
                    Text("Émotion ressentie:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                TextField("Ex: Anxiété, tristesse, colère...", text: $emotionBefore)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(spacing: 16) {
                HStack {
                    Text("Intensité: \(intensityBefore)/10")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(intensityDescription(intensityBefore))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(intensityColor(intensityBefore))
                }
                
                Slider(
                    value: Binding(
                        get: { Double(intensityBefore) },
                        set: { intensityBefore = Int($0) }
                    ),
                    in: 1...10,
                    step: 1
                )
                .accentColor(intensityColor(intensityBefore))
                
                HStack {
                    Text("Légère")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Très intense")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var distortionsStep: some View {
        VStack(spacing: 16) {
            Text("Sélectionnez les distorsions que vous reconnaissez dans votre pensée:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                ForEach(CognitiveDistortion.allCases, id: \.self) { distortion in
                    DistortionSelectionCard(
                        distortion: distortion,
                        isSelected: selectedDistortions.contains(distortion)
                    ) {
                        if selectedDistortions.contains(distortion) {
                            selectedDistortions.removeAll { $0 == distortion }
                        } else {
                            selectedDistortions.append(distortion)
                        }
                        AudioManager.shared.playHapticFeedback()
                    }
                }
            }
        }
    }
    
    private var reframeStep: some View {
        VStack(spacing: 16) {
            // Rappel de la pensée automatique
            VStack(alignment: .leading, spacing: 8) {
                Text("Pensée automatique:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(automaticThought)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .italic()
                    .padding()
                    .background(Color(.quaternarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Suggestion basée sur les distortions
            if !selectedDistortions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggestion:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                    
                    Text(viewModel.getSuggestedBalancedThought(for: automaticThought, distortions: selectedDistortions))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.quaternarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // Zone de saisie pour la pensée équilibrée
            VStack(alignment: .leading, spacing: 8) {
                Text("Pensée plus équilibrée:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                TextEditor(text: $balancedThought)
                    .frame(minHeight: 120)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Questions guidées
            VStack(alignment: .leading, spacing: 8) {
                Text("Questions pour vous aider:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                ForEach(viewModel.getGuidedQuestions(for: selectedDistortions), id: \.self) { question in
                    Text("• \(question)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.quaternarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var outcomeStep: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Après avoir reformulé votre pensée:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(balancedThought.isEmpty ? "Votre pensée équilibrée" : balancedThought)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .italic()
                    .padding()
                    .background(Color(.quaternarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(spacing: 16) {
                TextField("Nouvelle émotion ressentie", text: $emotionAfter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Nouvelle intensité: \(intensityAfter)/10")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(intensityDescription(intensityAfter))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(intensityColor(intensityAfter))
                    }
                    
                    Slider(
                        value: Binding(
                            get: { Double(intensityAfter) },
                            set: { intensityAfter = Int($0) }
                        ),
                        in: 1...10,
                        step: 1
                    )
                    .accentColor(intensityColor(intensityAfter))
                }
            }
            
            // Comparaison avant/après
            if intensityAfter < intensityBefore {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.green)
                    Text("Amélioration de \(intensityBefore - intensityAfter) points")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    private var actionStep: some View {
        VStack(spacing: 16) {
            TextEditor(text: $actionPlan)
                .frame(minHeight: 120)
                .padding()
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Idées d'actions:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("• Parler à quelqu'un de confiance")
                    Text("• Rechercher des informations objectives")
                    Text("• Pratiquer une technique de relaxation")
                    Text("• Faire une activité qui me fait du bien")
                    Text("• Planifier comment réagir différemment")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.quaternarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var completionStep: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Excellent travail !")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Vous avez terminé un exercice de restructuration cognitive. Cette pratique renforce votre capacité à gérer les pensées difficiles.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Résumé des changements
            if intensityAfter < intensityBefore {
                VStack(spacing: 12) {
                    Text("Amélioration constatée")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("Avant")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(intensityBefore)/10")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.secondary)
                        
                        VStack {
                            Text("Après")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(intensityAfter)/10")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button("Terminer") {
                dismiss()
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
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep.rawValue > 0 {
                Button("Précédent") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = CBTStep(rawValue: currentStep.rawValue - 1) ?? .situation
                    }
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.quaternarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button(nextButtonTitle) {
                nextAction()
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(canProceed ? Color.purple : Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(!canProceed)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var nextButtonTitle: String {
        switch currentStep {
        case .situation, .thought, .emotion, .distortions, .reframe, .outcome:
            return "Suivant"
        case .action:
            return "Sauvegarder"
        case .complete:
            return "Terminer"
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case .situation:
            return !situation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .thought:
            return !automaticThought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .emotion:
            return !emotionBefore.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .distortions:
            return true // Optionnel
        case .reframe:
            return !balancedThought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .outcome:
            return !emotionAfter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .action, .complete:
            return true
        }
    }
    
    private func nextAction() {
        switch currentStep {
        case .situation, .thought, .emotion, .distortions, .reframe, .outcome:
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = CBTStep(rawValue: currentStep.rawValue + 1) ?? .complete
            }
        case .action:
            saveThoughtRecord()
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = .complete
            }
        case .complete:
            dismiss()
        }
        
        AudioManager.shared.playHapticFeedback()
    }
    
    private func saveThoughtRecord() {
        let record = viewModel.createThoughtRecord(
            situation: situation,
            automaticThought: automaticThought,
            emotionBefore: emotionBefore,
            intensityBefore: intensityBefore
        )
        
        viewModel.updateThoughtRecord(
            record,
            cognitiveDistortions: selectedDistortions.map { $0.rawValue },
            balancedThought: balancedThought.isEmpty ? nil : balancedThought,
            emotionAfter: emotionAfter.isEmpty ? nil : emotionAfter,
            intensityAfter: intensityAfter,
            actionPlan: actionPlan.isEmpty ? nil : actionPlan
        )
        
        thoughtRecord = record
    }
    
    private func intensityColor(_ intensity: Int) -> Color {
        switch intensity {
        case 1...3: return .green
        case 4...6: return .orange
        default: return .red
        }
    }
    
    private func intensityDescription(_ intensity: Int) -> String {
        switch intensity {
        case 1...2: return "Légère"
        case 3...4: return "Modérée"
        case 5...6: return "Moyenne"
        case 7...8: return "Forte"
        default: return "Très forte"
        }
    }
}

struct DistortionSelectionCard: View {
    let distortion: CognitiveDistortion
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .purple : .secondary)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(distortion.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(distortion.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.1) : Color(.tertiarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let thoughtRecordViewModel = ThoughtRecordViewModel()
    return NewThoughtRecordView()
        .environmentObject(thoughtRecordViewModel)
}