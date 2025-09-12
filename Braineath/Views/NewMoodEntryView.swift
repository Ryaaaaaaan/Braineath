//
//  NewMoodEntryView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI

struct NewMoodEntryView: View {
    @EnvironmentObject var viewModel: MoodViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: Step = .emotion
    @State private var showingEmotion = false
    
    enum Step: Int, CaseIterable {
        case emotion = 0
        case intensity = 1
        case context = 2
        case notes = 3
        case complete = 4
        
        var title: String {
            switch self {
            case .emotion: return "Émotion"
            case .intensity: return "Intensité"
            case .context: return "Contexte"
            case .notes: return "Notes"
            case .complete: return "Terminé"
            }
        }
        
        var description: String {
            switch self {
            case .emotion: return "Comment vous sentez-vous maintenant ?"
            case .intensity: return "À quel point ressentez-vous cette émotion ?"
            case .context: return "Votre état général du moment"
            case .notes: return "Partagez vos pensées (optionnel)"
            case .complete: return "Entrée sauvegardée avec succès !"
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
                        case .emotion:
                            emotionSelectionView
                        case .intensity:
                            intensitySelectionView
                        case .context:
                            contextSelectionView
                        case .notes:
                            notesView
                        case .complete:
                            completionView
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                    .onTapGesture {
                        // Ferme le clavier quand on tape en dehors des champs de saisie
                        hideKeyboard()
                    }
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
                
                Text("Étape \(currentStep.rawValue + 1) sur \(Step.allCases.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            ProgressView(value: Double(currentStep.rawValue), total: Double(Step.allCases.count - 1))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal)
        }
        .padding(.top)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text(currentStep.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(currentStep.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var emotionSelectionView: some View {
        VStack(spacing: 24) {
            // Émotions suggérées en premier
            if !viewModel.suggestedEmotions.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text("Suggestions pour vous")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(viewModel.suggestedEmotions, id: \.id) { emotion in
                            EmotionCard(
                                emotion: emotion,
                                isSelected: viewModel.selectedEmotion?.id == emotion.id
                            ) {
                                viewModel.selectedEmotion = emotion
                                AudioManager.shared.playHapticFeedback()
                            }
                        }
                    }
                }
            }
            
            // Toutes les émotions par catégorie
            ForEach(EmotionCategory.allCases, id: \.self) { category in
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: categoryIcon(for: category))
                            .foregroundColor(category.color)
                        Text(category.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(Emotion.allEmotions.filter { $0.category == category }, id: \.id) { emotion in
                            EmotionCard(
                                emotion: emotion,
                                isSelected: viewModel.selectedEmotion?.id == emotion.id,
                                compact: true
                            ) {
                                viewModel.selectedEmotion = emotion
                                AudioManager.shared.playHapticFeedback()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var intensitySelectionView: some View {
        VStack(spacing: 32) {
            if let emotion = viewModel.selectedEmotion {
                VStack(spacing: 16) {
                    Image(systemName: emotion.icon)
                        .font(.system(size: 60))
                        .foregroundColor(Color(UIColor(hex: emotion.color) ?? .systemBlue))
                    
                    Text(emotion.name)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            
            VStack(spacing: 24) {
                Text("Intensité: \(viewModel.emotionIntensity)/10")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                IntensitySlider(
                    value: $viewModel.emotionIntensity,
                    color: viewModel.selectedEmotion?.color ?? "#007AFF"
                )
                
                HStack {
                    Text("Léger")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Intense")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var contextSelectionView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                ContextSlider(
                    title: "Niveau d'énergie",
                    value: $viewModel.energyLevel,
                    color: .orange,
                    lowLabel: "Épuisé",
                    highLabel: "Énergique",
                    icon: "bolt.fill"
                )
                
                ContextSlider(
                    title: "Niveau de stress",
                    value: $viewModel.stressLevel,
                    color: .red,
                    lowLabel: "Détendu",
                    highLabel: "Stressé",
                    icon: "exclamationmark.triangle.fill"
                )
                
                if viewModel.sleepQuality == nil {
                    Button("Ajouter qualité du sommeil") {
                        viewModel.sleepQuality = 5
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                
                if let _ = viewModel.sleepQuality {
                    ContextSlider(
                        title: "Qualité du sommeil",
                        value: Binding(
                            get: { viewModel.sleepQuality ?? 5 },
                            set: { viewModel.sleepQuality = $0 }
                        ),
                        color: .purple,
                        lowLabel: "Mauvais",
                        highLabel: "Excellent",
                        icon: "moon.fill"
                    )
                }
            }
            
            // Section triggers
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.blue)
                    Text("Déclencheurs (optionnel)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                TriggersSelectionView(selectedTriggers: $viewModel.triggers)
            }
        }
    }
    
    private var notesView: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "quote.bubble.fill")
                        .foregroundColor(.green)
                    Text("Vos pensées")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 120)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .onTapGesture {
                        // Permet de garder le focus sur le TextEditor quand on tape dessus
                    }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Suggestions d'écriture:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Qu'est-ce qui a déclenché cette émotion ?")
                    Text("• Comment votre corps réagit-il ?")
                    Text("• Y a-t-il quelque chose que vous aimeriez changer ?")
                    Text("• Qu'avez-vous appris sur vous aujourd'hui ?")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.quaternarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Entrée sauvegardée !")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Merci de prendre soin de votre bien-être mental.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Résumé de l'entrée
            if let emotion = viewModel.selectedEmotion {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: emotion.icon)
                            .foregroundColor(Color(UIColor(hex: emotion.color) ?? .systemBlue))
                        Text(emotion.name)
                            .fontWeight(.semibold)
                        Text("(\(viewModel.emotionIntensity)/10)")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    if !viewModel.notes.isEmpty {
                        Text("« \(viewModel.notes) »")
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button("Continuer") {
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
                        currentStep = Step(rawValue: currentStep.rawValue - 1) ?? .emotion
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
            .background(
                canProceed ? Color.blue : Color.gray
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(!canProceed)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var nextButtonTitle: String {
        switch currentStep {
        case .emotion, .intensity, .context:
            return "Suivant"
        case .notes:
            return "Sauvegarder"
        case .complete:
            return "Terminer"
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case .emotion:
            return viewModel.selectedEmotion != nil
        case .intensity, .context, .notes:
            return true
        case .complete:
            return true
        }
    }
    
    private func nextAction() {
        switch currentStep {
        case .emotion, .intensity, .context:
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = Step(rawValue: currentStep.rawValue + 1) ?? .complete
            }
        case .notes:
            // Sauvegarder l'entrée
            viewModel.saveMoodEntry()
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = .complete
            }
        case .complete:
            dismiss()
        }
        
        AudioManager.shared.playHapticFeedback()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func categoryIcon(for category: EmotionCategory) -> String {
        switch category {
        case .positive:
            return "sun.max.fill"
        case .negative:
            return "cloud.fill"
        case .neutral:
            return "circle.fill"
        }
    }
}

// Composants auxiliaires
struct EmotionCard: View {
    let emotion: Emotion
    let isSelected: Bool
    var compact: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: compact ? 8 : 12) {
                Image(systemName: emotion.icon)
                    .font(compact ? .title2 : .title)
                    .foregroundColor(Color(UIColor(hex: emotion.color) ?? .systemBlue))
                
                Text(emotion.name)
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(compact ? 12 : 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.tertiarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct IntensitySlider: View {
    @Binding var value: Int
    let color: String
    
    var body: some View {
        VStack(spacing: 16) {
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0) }
                ),
                in: 1...10,
                step: 1
            ) {
                Text("Intensité")
            }
            .accentColor(Color(UIColor(hex: color) ?? .systemBlue))
            
            HStack {
                ForEach(1...10, id: \.self) { number in
                    Text("\(number)")
                        .font(.caption)
                        .fontWeight(value == number ? .bold : .regular)
                        .foregroundColor(value == number ? Color(UIColor(hex: color) ?? .systemBlue) : .secondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct ContextSlider: View {
    let title: String
    @Binding var value: Int
    let color: Color
    let lowLabel: String
    let highLabel: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(value)/10")
                    .font(.subheadline)
                    .foregroundColor(color)
            }
            
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0) }
                ),
                in: 1...10,
                step: 1
            )
            .accentColor(color)
            
            HStack {
                Text(lowLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(highLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct TriggersSelectionView: View {
    @Binding var selectedTriggers: [String]
    @State private var customTrigger = ""
    
    private let commonTriggers = [
        "Travail", "Relations", "Santé", "Finances", "Famille",
        "Sommeil", "Météo", "Actualités", "Réseaux sociaux", "Transport"
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80))
            ], spacing: 8) {
                ForEach(commonTriggers, id: \.self) { trigger in
                    TriggerChip(
                        text: trigger,
                        isSelected: selectedTriggers.contains(trigger)
                    ) {
                        if selectedTriggers.contains(trigger) {
                            selectedTriggers.removeAll { $0 == trigger }
                        } else {
                            selectedTriggers.append(trigger)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Autre déclencheur...", text: $customTrigger)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        if !customTrigger.isEmpty && !selectedTriggers.contains(customTrigger) {
                            selectedTriggers.append(customTrigger)
                            customTrigger = ""
                        }
                    }
                
                Button("Ajouter") {
                    if !customTrigger.isEmpty && !selectedTriggers.contains(customTrigger) {
                        selectedTriggers.append(customTrigger)
                        customTrigger = ""
                    }
                }
                .disabled(customTrigger.isEmpty)
            }
        }
    }
}

struct TriggerChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(.tertiarySystemBackground))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let moodViewModel = MoodViewModel()
    return NewMoodEntryView()
        .environmentObject(moodViewModel)
}