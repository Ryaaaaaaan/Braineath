//
//  BreathingSettingsView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI

struct BreathingSettingsView: View {
    @EnvironmentObject var viewModel: BreathingViewModel
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Section Audio
                Section("Audio") {
                    Toggle("Sons activés", isOn: $viewModel.soundEnabled)
                    
                    if viewModel.soundEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Son d'ambiance")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Picker("Son d'ambiance", selection: $viewModel.selectedSound) {
                                ForEach(AudioManager.BreathingSound.allCases, id: \.self) { sound in
                                    VStack(alignment: .leading) {
                                        Text(sound.rawValue)
                                        Text(sound.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .tag(sound)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            if audioManager.isPlaying {
                                Button("Arrêter l'aperçu") {
                                    audioManager.stopCurrentSound()
                                }
                                .foregroundColor(.red)
                            } else {
                                Button("Tester le son") {
                                    audioManager.playBreathingSound(viewModel.selectedSound)
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Volume: \(Int(audioManager.volume * 100))%")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Slider(value: $audioManager.volume, in: 0...1) {
                                Text("Volume")
                            }
                            .onChange(of: audioManager.volume) { newValue in
                                audioManager.setVolume(Float(newValue))
                            }
                        }
                    }
                }
                
                // Section Haptiques
                Section("Retours haptiques") {
                    Toggle("Vibrations activées", isOn: $viewModel.hapticEnabled)
                    
                    if viewModel.hapticEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Les vibrations vous aident à suivre les transitions de respiration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button("Tester les vibrations") {
                                AudioManager.shared.playHapticFeedback(style: .light)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    AudioManager.shared.playHapticFeedback(style: .medium)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    AudioManager.shared.playHapticFeedback(style: .heavy)
                                }
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                // Section Patterns préférés
                Section("Patterns de respiration") {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Pattern par défaut")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("Pattern par défaut", selection: $viewModel.selectedPattern) {
                            ForEach(BreathingPattern.allCases, id: \.self) { pattern in
                                VStack(alignment: .leading) {
                                    Text(pattern.rawValue)
                                        .font(.subheadline)
                                    Text(pattern.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .tag(pattern)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Section Durées personnalisées
                Section("Durées de session") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Durée par défaut")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("\(viewModel.sessionDuration) minutes")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Stepper(value: $viewModel.sessionDuration, in: 1...60, step: 1) {
                                EmptyView()
                            }
                        }
                        
                        Text("Sessions recommandées :")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach([3, 5, 10, 15, 20, 30], id: \.self) { duration in
                                Button("\(duration)m") {
                                    viewModel.sessionDuration = duration
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(viewModel.sessionDuration == duration ? Color.blue : Color(.tertiarySystemBackground))
                                )
                                .foregroundColor(viewModel.sessionDuration == duration ? .white : .primary)
                            }
                        }
                    }
                }
                
                // Section Notifications
                Section("Rappels de respiration") {
                    Toggle("Rappels quotidiens", isOn: .constant(true))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Fréquence des rappels")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("Fréquence", selection: .constant("Quotidien")) {
                            Text("Jamais").tag("Jamais")
                            Text("Quotidien").tag("Quotidien")
                            Text("2x par jour").tag("2x par jour")
                            Text("3x par jour").tag("3x par jour")
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Text("Les rappels vous encouragent à maintenir une pratique régulière de respiration consciente.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Section Statistiques et données
                Section("Données et statistiques") {
                    NavigationLink("Voir les statistiques détaillées") {
                        BreathingStatsView()
                            .environmentObject(viewModel)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Sessions enregistrées")
                            Spacer()
                            Text("\(viewModel.recentSessions.count)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Minutes totales")
                            Spacer()
                            Text("\(viewModel.totalMinutesThisWeek)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Série actuelle")
                            Spacer()
                            Text("\(viewModel.streakDays) jours")
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.subheadline)
                }
                
                // Section Réinitialisation
                Section("Réinitialisation") {
                    Button("Réinitialiser les préférences") {
                        resetToDefaults()
                    }
                    .foregroundColor(.orange)
                    
                    Button("Effacer toutes les sessions") {
                        // Action pour effacer les données
                    }
                    .foregroundColor(.red)
                    
                    Text("Ces actions sont irréversibles.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Paramètres respiration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Terminé") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func resetToDefaults() {
        viewModel.selectedPattern = .basic478
        viewModel.sessionDuration = 5
        viewModel.selectedSound = .silence
        viewModel.soundEnabled = true
        viewModel.hapticEnabled = true
        audioManager.volume = 0.7
        audioManager.stopCurrentSound()
    }
}

#Preview {
    let breathingViewModel = BreathingViewModel()
    let audioManager = AudioManager.shared
    
    return BreathingSettingsView()
        .environmentObject(breathingViewModel)
        .environmentObject(audioManager)
}