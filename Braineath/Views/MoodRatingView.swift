//
//  MoodRatingView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI

struct MoodRatingView: View {
    @EnvironmentObject var viewModel: BreathingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMood: Int = 5
    @State private var isForBefore: Bool = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                // Titre
                VStack(spacing: 16) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.pink)
                    
                    Text(isForBefore ? "Comment vous sentez-vous ?" : "Comment vous sentez-vous maintenant ?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(isForBefore ? "Avant de commencer" : "Après la session")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Sélection de l'humeur
                VStack(spacing: 24) {
                    Text("\(selectedMood)/10")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(colorForMood(selectedMood))
                    
                    // Slider d'humeur
                    VStack(spacing: 16) {
                        Slider(
                            value: Binding(
                                get: { Double(selectedMood) },
                                set: { selectedMood = Int($0) }
                            ),
                            in: 1...10,
                            step: 1
                        ) {
                            Text("Humeur")
                        }
                        .accentColor(colorForMood(selectedMood))
                        .onChange(of: selectedMood) { _ in
                            AudioManager.shared.playHapticFeedback(style: .light)
                        }
                        
                        // Échelle visuelle
                        HStack {
                            ForEach(1...10, id: \.self) { number in
                                Circle()
                                    .fill(selectedMood == number ? colorForMood(number) : Color.gray.opacity(0.3))
                                    .frame(width: selectedMood == number ? 16 : 12, height: selectedMood == number ? 16 : 12)
                                    .animation(.easeInOut(duration: 0.2), value: selectedMood)
                            }
                        }
                        
                        HStack {
                            Text("Très mal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Excellent")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Description de l'humeur
                VStack(spacing: 8) {
                    Text(moodDescription(for: selectedMood))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(moodSubtitle(for: selectedMood))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Boutons
                HStack(spacing: 16) {
                    Button("Passer") {
                        handleSkip()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 100, height: 44)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    
                    Button("Confirmer") {
                        handleConfirm()
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(colorForMood(selectedMood))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .onAppear {
            determineRatingContext()
        }
    }
    
    private func determineRatingContext() {
        // Déterminer si c'est pour avant ou après la session
        isForBefore = viewModel.moodBefore == nil
        selectedMood = isForBefore ? 5 : (viewModel.moodBefore ?? 5)
    }
    
    private func handleConfirm() {
        if isForBefore {
            viewModel.moodBefore = selectedMood
            // Si c'est avant, fermer et continuer la session
            dismiss()
        } else {
            viewModel.moodAfter = selectedMood
            dismiss()
        }
        
        AudioManager.shared.playHapticFeedback(style: .medium)
    }
    
    private func handleSkip() {
        dismiss()
    }
    
    private func colorForMood(_ mood: Int) -> Color {
        switch mood {
        case 1...3:
            return .red
        case 4...6:
            return .orange
        case 7...8:
            return .yellow
        case 9...10:
            return .green
        default:
            return .gray
        }
    }
    
    private func moodDescription(for mood: Int) -> String {
        switch mood {
        case 1:
            return "Très difficile"
        case 2:
            return "Difficile"
        case 3:
            return "Pas terrible"
        case 4:
            return "Moyen-"
        case 5:
            return "Neutre"
        case 6:
            return "Moyen+"
        case 7:
            return "Plutôt bien"
        case 8:
            return "Bien"
        case 9:
            return "Très bien"
        case 10:
            return "Excellent"
        default:
            return "Neutre"
        }
    }
    
    private func moodSubtitle(for mood: Int) -> String {
        switch mood {
        case 1...3:
            return "Courage, ce moment passera"
        case 4...6:
            return "C'est normal d'avoir des hauts et des bas"
        case 7...8:
            return "Belle énergie positive"
        case 9...10:
            return "Magnifique ! Savourez ce moment"
        default:
            return "Prenez le temps de ressentir"
        }
    }
}

#Preview {
    let breathingViewModel = BreathingViewModel()
    return MoodRatingView()
        .environmentObject(breathingViewModel)
}