//
//  MainTabView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var moodViewModel = MoodViewModel()
    @StateObject private var breathingViewModel = BreathingViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Onglet Dashboard/Accueil
            DashboardView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Accueil")
                }
                .tag(0)
            
            // Onglet Journal Émotionnel
            MoodJournalView()
                .environmentObject(moodViewModel)
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "heart.fill" : "heart")
                    Text("Humeur")
                }
                .tag(1)
            
            // Onglet Respiration (central et plus gros)
            BreathingView()
                .environmentObject(breathingViewModel)
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "lungs.fill" : "lungs")
                    Text("Respirer")
                }
                .tag(2)
            
            // Onglet Outils TCC
            ThoughtRecordView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "brain.head.profile.fill" : "brain.head.profile")
                    Text("Pensées")
                }
                .tag(3)
            
            // Onglet Espaces Privés (Gratitude, etc.)
            PrivateSpaceView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "book.fill" : "book")
                    Text("Journal")
                }
                .tag(4)
        }
        .accentColor(.primary)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        if colorScheme == .dark {
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        } else {
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        }
        
        // Style pour l'item sélectionné
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]
        
        // Style pour l'item normal
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}