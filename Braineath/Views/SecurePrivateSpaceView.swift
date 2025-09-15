//
//  SecurePrivateSpaceView.swift
//  Braineath
//
//  Created by Ryan Zemri on 15/09/2025.
//

import SwiftUI

struct SecurePrivateSpaceView: View {
    @StateObject private var authManager = BiometricAuthManager.shared
    @EnvironmentObject var thoughtRecordViewModel: ThoughtRecordViewModel
    @EnvironmentObject var gratitudeViewModel: GratitudeViewModel
    @EnvironmentObject var intentionsViewModel: IntentionsViewModel
    
    @State private var isUnlocked = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.1),
                        Color.blue.opacity(0.05),
                        Color.indigo.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                )
                .ignoresSafeArea()
                
                if isUnlocked {
                    // Content when unlocked
                    VStack(spacing: 0) {
                        // Custom tab selector
                        tabSelector
                        
                        // Content based on selected tab
                        TabView(selection: $selectedTab) {
                            // Thought Records
                            ThoughtRecordContentView()
                                .environmentObject(thoughtRecordViewModel)
                                .tag(0)
                            
                            // Gratitude & Intentions
                            PrivateSpaceContentView()
                                .environmentObject(gratitudeViewModel)
                                .environmentObject(intentionsViewModel)
                                .tag(1)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                } else {
                    // Locked state
                    lockedStateView
                }
            }
        }
        .navigationBarHidden(isUnlocked)
        .onAppear {
            checkBiometricAuth()
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<2, id: \.self) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: index == 0 ? "brain.head.profile.fill" : "heart.text.square.fill")
                            .font(.title2)
                            .foregroundColor(selectedTab == index ? .blue : .secondary)
                        
                        Text(index == 0 ? "Pensées" : "Bien-être privé")
                            .font(.caption)
                            .fontWeight(selectedTab == index ? .semibold : .regular)
                            .foregroundColor(selectedTab == index ? .blue : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Rectangle()
                            .fill(selectedTab == index ? Color.blue.opacity(0.1) : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var lockedStateView: some View {
        VStack(spacing: 30) {
            // Lock icon with glow effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                .blue.opacity(0.3),
                                .purple.opacity(0.1)
                            ]),
                            center: .center,
                            startRadius: 30,
                            endRadius: 100
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: authManager.biometricIcon)
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 16) {
                Text("Espace Privé Sécurisé")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Vos pensées et réflexions personnelles sont protégées par \(authManager.biometricTypeDescription)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if authManager.isBiometricAvailable {
                    Button(action: authenticateUser) {
                        HStack(spacing: 12) {
                            Image(systemName: authManager.biometricIcon)
                                .font(.title2)
                            
                            Text("Déverrouiller avec \(authManager.biometricTypeDescription)")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 12) {
                        Text("Authentification biométrique non disponible")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        
                        Button("Accéder sans protection") {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isUnlocked = true
                            }
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
    }
    
    private func checkBiometricAuth() {
        // Auto-unlock if biometric is not available or not enabled
        if !authManager.isBiometricAvailable || !authManager.isAppLocked {
            withAnimation(.easeInOut(duration: 0.5)) {
                isUnlocked = true
            }
        } else if authManager.isBiometricAvailable && authManager.isAppLocked {
            // Trigger biometric authentication automatically
            authenticateUser()
        }
    }
    
    private func authenticateUser() {
        authManager.authenticateUser { success in
            DispatchQueue.main.async {
                if success {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isUnlocked = true
                    }
                }
            }
        }
    }
}

// Content view for thought records
struct ThoughtRecordContentView: View {
    @EnvironmentObject var viewModel: ThoughtRecordViewModel
    @State private var showingNewRecord = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Restructuration Cognitive")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Analysez et transformez vos pensées")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showingNewRecord = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            // Content
            if viewModel.thoughtRecords.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("Commencez votre premier enregistrement de pensées")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("La restructuration cognitive vous aide à identifier et modifier les pensées négatives")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                Spacer()
            } else {
                ThoughtRecordsList()
                    .environmentObject(viewModel)
            }
        }
        .sheet(isPresented: $showingNewRecord) {
            NewThoughtRecordView()
                .environmentObject(viewModel)
        }
    }
}

// Simplified thought records list
struct ThoughtRecordsList: View {
    @EnvironmentObject var viewModel: ThoughtRecordViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.thoughtRecords.prefix(10), id: \.objectID) { record in
                    ThoughtRecordCompactCard(record: record)
                }
            }
            .padding()
        }
    }
}

struct ThoughtRecordCompactCard: View {
    let record: ThoughtRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let situation = record.situation, !situation.isEmpty {
                        Text(situation)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                    }
                    
                    if let date = record.date {
                        Text(date, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if record.intensityBefore > 0 {
                    let intensity = Int(record.intensityBefore)
                    VStack(spacing: 2) {
                        Text("\(intensity)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(intensityColor(Int(intensity)))
                        
                        Text("Intensité")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if let thought = record.automaticThought, !thought.isEmpty {
                Text(thought)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .padding(.leading, 8)
                    .overlay(
                        Rectangle()
                            .fill(.blue)
                            .frame(width: 2)
                            .padding(.leading, 2),
                        alignment: .leading
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
    
    private func intensityColor(_ intensity: Int) -> Color {
        switch intensity {
        case 1...3: return .green
        case 4...6: return .orange
        default: return .red
        }
    }
}

// Content view for private space (gratitude & intentions)
struct PrivateSpaceContentView: View {
    @EnvironmentObject var gratitudeViewModel: GratitudeViewModel
    @EnvironmentObject var intentionsViewModel: IntentionsViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bien-être Privé")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Gratitude et intentions personnelles")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Quick gratitude
                    GratitudeQuickEntry()
                        .environmentObject(gratitudeViewModel)
                        .padding(.horizontal)
                    
                    // Daily intentions
                    IntentionsQuickEntry()
                        .environmentObject(intentionsViewModel)
                        .padding(.horizontal)
                    
                    // Extra padding to ensure buttons are visible above keyboard
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 200)
                }
                .padding(.top)
                .frame(minHeight: geometry.size.height)
            }
        }
    }
}

struct GratitudeQuickEntry: View {
    @EnvironmentObject var viewModel: GratitudeViewModel
    @State private var gratitudeText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                Text("Gratitude du jour")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            TextField("Pour quoi êtes-vous reconnaissant aujourd'hui ?", text: $gratitudeText, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
                .lineLimit(3...6)
                .focused($isTextFieldFocused)
                .onSubmit {
                    if !gratitudeText.isEmpty {
                        saveGratitude()
                    }
                }
            
            HStack {
                if !gratitudeText.isEmpty {
                    Button("Ajouter") {
                        saveGratitude()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.pink)
                    .clipShape(Capsule())
                }
                
                Spacer()
                
                if isTextFieldFocused {
                    Button("Fermer") {
                        isTextFieldFocused = false
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func saveGratitude() {
        guard !gratitudeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Save gratitude entry with timestamp
        let entry = [
            "text": gratitudeText,
            "date": Date().timeIntervalSince1970
        ] as [String: Any]
        
        // Get existing entries
        var existingEntries = UserDefaults.standard.array(forKey: "gratitudeEntries") as? [[String: Any]] ?? []
        existingEntries.append(entry)
        
        // Keep only last 100 entries
        if existingEntries.count > 100 {
            existingEntries = Array(existingEntries.suffix(100))
        }
        
        UserDefaults.standard.set(existingEntries, forKey: "gratitudeEntries")
        
        gratitudeText = ""
        isTextFieldFocused = false
        AudioManager.shared.playHapticFeedback()
    }
}

struct IntentionsQuickEntry: View {
    @EnvironmentObject var viewModel: IntentionsViewModel
    @State private var intentionText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.blue)
                Text("Intention du jour")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            TextField("Quelle est votre intention pour aujourd'hui ?", text: $intentionText, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
                .lineLimit(3...6)
                .focused($isTextFieldFocused)
                .onSubmit {
                    if !intentionText.isEmpty {
                        saveIntention()
                    }
                }
            
            HStack {
                if !intentionText.isEmpty {
                    Button("Définir") {
                        saveIntention()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .clipShape(Capsule())
                }
                
                Spacer()
                
                if isTextFieldFocused {
                    Button("Fermer") {
                        isTextFieldFocused = false
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func saveIntention() {
        guard !intentionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Save intention entry with timestamp
        let entry = [
            "text": intentionText,
            "date": Date().timeIntervalSince1970
        ] as [String: Any]
        
        // Get existing entries
        var existingEntries = UserDefaults.standard.array(forKey: "intentionEntries") as? [[String: Any]] ?? []
        existingEntries.append(entry)
        
        // Keep only last 100 entries
        if existingEntries.count > 100 {
            existingEntries = Array(existingEntries.suffix(100))
        }
        
        UserDefaults.standard.set(existingEntries, forKey: "intentionEntries")
        
        intentionText = ""
        isTextFieldFocused = false
        AudioManager.shared.playHapticFeedback()
    }
}

#Preview {
    let thoughtRecordViewModel = ThoughtRecordViewModel()
    let gratitudeViewModel = GratitudeViewModel()
    let intentionsViewModel = IntentionsViewModel()
    
    return SecurePrivateSpaceView()
        .environmentObject(thoughtRecordViewModel)
        .environmentObject(gratitudeViewModel)
        .environmentObject(intentionsViewModel)
}