//
//  PrivateSpaceView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI

struct PrivateSpaceView: View {
    @StateObject private var gratitudeViewModel = GratitudeViewModel()
    @StateObject private var intentionsViewModel = IntentionsViewModel()
    @State private var selectedTab: PrivateTab = .gratitude
    
    enum PrivateTab: String, CaseIterable {
        case gratitude = "Gratitude"
        case intentions = "Intentions"
        case reflections = "Réflexions"
        
        var icon: String {
            switch self {
            case .gratitude: return "heart.fill"
            case .intentions: return "target"
            case .reflections: return "book.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .gratitude: return .pink
            case .intentions: return .blue
            case .reflections: return .purple
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Sélecteur d'onglets personnalisé
                customTabSelector
                
                // Contenu selon l'onglet sélectionné
                ScrollView {
                    VStack(spacing: 24) {
                        switch selectedTab {
                        case .gratitude:
                            gratitudeContent
                        case .intentions:
                            intentionsContent
                        case .reflections:
                            reflectionsContent
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
            }
            .navigationTitle("Espaces privés")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
    
    private var customTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(PrivateTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: tab.icon)
                            .font(.title3)
                            .foregroundColor(selectedTab == tab ? tab.color : .secondary)
                        
                        Text(tab.rawValue)
                            .font(.caption)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .foregroundColor(selectedTab == tab ? tab.color : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedTab == tab ? tab.color.opacity(0.1) : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
    }
    
    private var gratitudeContent: some View {
        VStack(spacing: 24) {
            // En-tête gratitude
            VStack(spacing: 16) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.pink)
                
                Text("Journal de gratitude")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Trois choses pour lesquelles vous êtes reconnaissant(e) aujourd'hui")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Ajout rapide de gratitude
            quickGratitudeEntry
            
            // Statistiques de gratitude
            gratitudeStats
            
            // Entrées récentes
            recentGratitudeEntries
        }
    }
    
    private var intentionsContent: some View {
        VStack(spacing: 24) {
            // En-tête intentions
            VStack(spacing: 16) {
                Image(systemName: "target")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Intentions quotidiennes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Définissez vos intentions pour cultiver une vie consciente")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Intention du jour
            todaysIntention
            
            // Création d'intention
            intentionCreator
            
            // Intentions récentes
            recentIntentions
        }
    }
    
    private var reflectionsContent: some View {
        VStack(spacing: 24) {
            // En-tête réflexions
            VStack(spacing: 16) {
                Image(systemName: "book.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
                
                Text("Réflexions libres")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Un espace pour vos pensées, découvertes et insights personnels")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Écriture libre
            freeWritingSection
            
            // Prompts de réflexion
            reflectionPrompts
        }
    }
    
    private var quickGratitudeEntry: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Ajouter une gratitude")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                TextField("Pour quoi êtes-vous reconnaissant(e) ?", text: $gratitudeViewModel.newGratitudeText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                    .onSubmit {
                        gratitudeViewModel.addGratitudeEntry()
                    }
                
                HStack {
                    // Catégories rapides
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(gratitudeViewModel.categories, id: \.self) { category in
                                Button(category) {
                                    gratitudeViewModel.selectedCategory = category
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(gratitudeViewModel.selectedCategory == category ? Color.pink : Color(.tertiarySystemBackground))
                                )
                                .foregroundColor(gratitudeViewModel.selectedCategory == category ? .white : .primary)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Button("Ajouter") {
                        gratitudeViewModel.addGratitudeEntry()
                        AudioManager.shared.playHapticFeedback()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.pink)
                    .clipShape(Capsule())
                    .disabled(gratitudeViewModel.newGratitudeText.isEmpty)
                }
            }
        }
    }
    
    private var gratitudeStats: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Cette semaine",
                value: "\(gratitudeViewModel.entriesThisWeek)",
                color: .pink,
                icon: "heart.fill"
            )
            
            StatCard(
                title: "Total",
                value: "\(gratitudeViewModel.totalEntries)",
                color: .orange,
                icon: "sparkles"
            )
            
            StatCard(
                title: "Streak",
                value: "\(gratitudeViewModel.currentStreak) j",
                color: .green,
                icon: "flame.fill"
            )
        }
    }
    
    private var recentGratitudeEntries: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Récentes gratitudes")
                .font(.headline)
                .foregroundColor(.primary)
            
            if gratitudeViewModel.recentEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart")
                        .font(.system(size: 30))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("Ajoutez votre première gratitude")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(gratitudeViewModel.recentEntries, id: \.id) { entry in
                        GratitudeEntryRow(entry: entry)
                    }
                }
            }
        }
    }
    
    private var todaysIntention: some View {
        VStack(spacing: 16) {
            if let todayIntention = intentionsViewModel.todaysIntention {
                VStack(spacing: 12) {
                    HStack {
                        Text("Intention d'aujourd'hui")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            intentionsViewModel.toggleIntentionCompletion(todayIntention)
                        }) {
                            Image(systemName: todayIntention.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundColor(todayIntention.isCompleted ? .green : .secondary)
                        }
                    }
                    
                    Text(todayIntention.intentionText ?? "")
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(todayIntention.isCompleted ? Color.green.opacity(0.1) : Color(.tertiarySystemBackground))
                        )
                }
            } else {
                Text("Aucune intention définie pour aujourd'hui")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var intentionCreator: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Nouvelle intention")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 12) {
                TextField("Quelle est votre intention pour aujourd'hui ?", text: $intentionsViewModel.newIntentionText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(2...4)
                    .onSubmit {
                        intentionsViewModel.createIntention()
                    }
                
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(intentionsViewModel.intentionCategories, id: \.self) { category in
                                Button(category) {
                                    intentionsViewModel.selectedCategory = category
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(intentionsViewModel.selectedCategory == category ? Color.blue : Color(.tertiarySystemBackground))
                                )
                                .foregroundColor(intentionsViewModel.selectedCategory == category ? .white : .primary)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Button("Créer") {
                        intentionsViewModel.createIntention()
                        AudioManager.shared.playHapticFeedback()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .disabled(intentionsViewModel.newIntentionText.isEmpty)
                }
            }
        }
    }
    
    private var recentIntentions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Intentions récentes")
                .font(.headline)
                .foregroundColor(.primary)
            
            if intentionsViewModel.recentIntentions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "target")
                        .font(.system(size: 30))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("Créez votre première intention")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(intentionsViewModel.recentIntentions, id: \.id) { intention in
                        IntentionRow(intention: intention) {
                            intentionsViewModel.toggleIntentionCompletion(intention)
                        }
                    }
                }
            }
        }
    }
    
    private var freeWritingSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Écriture libre")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            TextEditor(text: $intentionsViewModel.freeWritingText)
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
            
            HStack {
                Text("\(intentionsViewModel.freeWritingText.count) caractères")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Sauvegarder") {
                    // Sauvegarder le texte libre
                    AudioManager.shared.playHapticFeedback()
                }
                .font(.caption)
                .disabled(intentionsViewModel.freeWritingText.isEmpty)
            }
        }
    }
    
    private var reflectionPrompts: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Prompts de réflexion")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 12) {
                ForEach(intentionsViewModel.reflectionPrompts, id: \.self) { prompt in
                    ReflectionPromptCard(prompt: prompt) {
                        intentionsViewModel.freeWritingText = prompt + "\n\n"
                    }
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Composants auxiliaires
struct GratitudeEntryRow: View {
    let entry: GratitudeEntry
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .foregroundColor(.pink)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.gratitudeText ?? "")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                HStack {
                    if let category = entry.category {
                        Text(category)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.pink.opacity(0.2))
                            .foregroundColor(.pink)
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    if let date = entry.date {
                        Text(date, style: .relative)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct IntentionRow: View {
    let intention: DailyIntention
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: intention.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(intention.isCompleted ? .green : .secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(intention.intentionText ?? "")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .strikethrough(intention.isCompleted)
                
                HStack {
                    if let category = intention.category {
                        Text(category)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    if let date = intention.date {
                        Text(date, style: .date)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ReflectionPromptCard: View {
    let prompt: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "quote.bubble")
                    .foregroundColor(.purple)
                    .font(.title3)
                
                Text(prompt)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PrivateSpaceView()
}