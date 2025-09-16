//
//  AppSettingsView.swift
//  Braineath
//
//  Created by Ryan Zemri on 15/09/2025.
//

import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject var breathingViewModel: BreathingViewModel
    @EnvironmentObject var moodViewModel: MoodViewModel
    @StateObject private var profileManager = UserProfileManager.shared
    @StateObject private var authManager = BiometricAuthManager.shared
    @StateObject private var audioManager = AudioManager.shared
    
    @State private var showingBreathingSettings = false
    @State private var showingAbout = false
    @State private var showingPrivacy = false
    
    private var formattedMemberSince: String {
        if let profile = profileManager.currentProfile {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: profile.createdAt)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: Date())
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                profileSection
                
                // App Settings
                appPreferencesSection
                
                // Module Settings
                moduleSettingsSection
                
                // Privacy & Security
                privacySecuritySection
                
                // Support & Info
                supportInfoSection
                
                // Data Management
                dataManagementSection
            }
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingBreathingSettings) {
            BreathingSettingsView()
                .environmentObject(breathingViewModel)
                .environmentObject(audioManager)
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacyView()
        }
    }
    
    private var profileSection: some View {
        Section {
            HStack(spacing: 16) {
                // Profile Avatar
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(String(profileManager.currentProfile?.name.prefix(1) ?? "U").uppercased())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profileManager.currentProfile?.name ?? "Utilisateur")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Braineath Premium")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Membre depuis \(formattedMemberSince)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                // Navigate to profile editing
            }
        }
    }
    
    private var appPreferencesSection: some View {
        Section("Préférences générales") {
            
            
            // Haptic Feedback
            HStack {
                Image(systemName: "iphone.radiowaves.left.and.right")
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                Toggle("Retour haptique", isOn: $breathingViewModel.hapticEnabled)
            }
            
            // Sound Effects
            HStack {
                Image(systemName: "speaker.wave.2")
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                Toggle("Effets sonores", isOn: $breathingViewModel.soundEnabled)
            }
        }
    }
    
    private var moduleSettingsSection: some View {
        Section("Modules") {
            // Breathing Settings
            HStack {
                Image(systemName: "lungs.fill")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text("Respiration")
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showingBreathingSettings = true
            }
        }
    }
    
    private var privacySecuritySection: some View {
        Section("Confidentialité et sécurité") {
            // Biometric Lock
            if authManager.isBiometricAvailable {
                HStack {
                    Image(systemName: authManager.biometricIcon)
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Verrouillage par \(authManager.biometricTypeDescription)")
                        Text("Protégez vos données personnelles")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { authManager.isAppLocked },
                        set: { authManager.enableAppLock($0) }
                    ))
                }
            }
            
            // Privacy Policy
            HStack {
                Image(systemName: "hand.raised")
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                Text("Politique de confidentialité")
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showingPrivacy = true
            }
            
            // Data Encryption
            HStack {
                Image(systemName: "lock.shield")
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Données chiffrées")
                    Text("Stockage local sécurisé")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
    
    private var supportInfoSection: some View {
        Section("Support et informations") {
            
            // About
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.gray)
                    .frame(width: 24)
                
                Text("À propos de Braineath")
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showingAbout = true
            }
            
        }
    }
    
    private var dataManagementSection: some View {
        Section("Gestion des données") {
            
            // Reset Settings
            HStack {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                Text("Réinitialiser les préférences")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                resetAllSettings()
            }
            
            // Delete All Data
            HStack {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .frame(width: 24)
                
                Text("Supprimer toutes les données")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // Show confirmation alert
            }
        }
        .foregroundColor(.primary)
    }
    
    private func resetAllSettings() {
        // Reset all settings to defaults
        breathingViewModel.selectedPattern = .basic478
        breathingViewModel.sessionDuration = 5
        breathingViewModel.selectedSound = .silence
        breathingViewModel.soundEnabled = true
        breathingViewModel.hapticEnabled = true
        audioManager.volume = 0.7
        audioManager.stopCurrentSound()
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon
                    Image("AppIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 10)
                    
                    VStack(spacing: 8) {
                        Text("Braineath")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Votre compagnon de bien-être mental")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Braineath vous accompagne dans votre parcours de bien-être mental avec des exercices de respiration, un journal d'humeur et des outils de restructuration cognitive basés sur la thérapie cognitive-comportementale.")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        
                        Text("Développé avec ❤️ par Ryan Zemri")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("À propos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Vos données restent privées")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        privacyPoint(
                            icon: "iphone",
                            title: "Stockage local",
                            description: "Toutes vos données sont stockées localement sur votre appareil et ne quittent jamais votre iPhone."
                        )
                        
                        privacyPoint(
                            icon: "lock.shield",
                            title: "Chiffrement",
                            description: "Vos données sensibles sont chiffrées et protégées par les systèmes de sécurité iOS."
                        )
                        
                        privacyPoint(
                            icon: "network.slash",
                            title: "Pas de tracking",
                            description: "Nous ne collectons aucune donnée analytique, ne vous suivons pas et ne partageons rien avec des tiers."
                        )
                        
                        privacyPoint(
                            icon: "person.badge.shield.checkmark",
                            title: "Contrôle total",
                            description: "Vous gardez un contrôle total sur vos données. Exportez ou supprimez vos informations à tout moment."
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Confidentialité")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
    
    private func privacyPoint(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    let breathingViewModel = BreathingViewModel()
    let moodViewModel = MoodViewModel()
    
    return AppSettingsView()
        .environmentObject(breathingViewModel)
        .environmentObject(moodViewModel)
}