//
//  MainTabViewWithNewDashboard.swift
//  Braineath
//
//  Created by Ryan Zemri on 12/09/2025.
//

import SwiftUI

struct MainTabViewWithNewDashboard: View {
    @StateObject private var moodViewModel = MoodViewModel()
    @StateObject private var breathingViewModel = BreathingViewModel()
    @StateObject private var thoughtRecordViewModel = ThoughtRecordViewModel()
    @StateObject private var gratitudeViewModel = GratitudeViewModel()
    @StateObject private var intentionsViewModel = IntentionsViewModel()
    @StateObject private var emergencyViewModel = EmergencyViewModel()
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Beautiful Dashboard (Home)
            NavigationView {
                BeautifulDashboardView()
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                Text("Accueil")
            }
            .tag(0)
            .environmentObject(moodViewModel)
            .environmentObject(breathingViewModel)
            
            // Breathing Exercises
            NavigationView {
                BreathingView()
                    .navigationTitle("Respiration")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Image(systemName: selectedTab == 1 ? "lungs.fill" : "lungs")
                Text("Respirer")
            }
            .tag(1)
            .environmentObject(breathingViewModel)
            
            // Mood Journal
            NavigationView {
                MoodJournalView()
                    .navigationTitle("Journal d'humeur")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Image(systemName: selectedTab == 2 ? "heart.fill" : "heart")
                Text("Humeur")
            }
            .tag(2)
            .environmentObject(moodViewModel)
            
            // Private Space (Gratitude, Intentions, etc.)
            NavigationView {
                PrivateSpaceView()
                    .navigationTitle("Espace Privé")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Image(systemName: selectedTab == 3 ? "person.crop.circle.fill" : "person.crop.circle")
                Text("Privé")
            }
            .tag(3)
            .environmentObject(gratitudeViewModel)
            .environmentObject(intentionsViewModel)
            
            // Thought Record
            NavigationView {
                ThoughtRecordView()
                    .navigationTitle("Pensées")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Image(systemName: selectedTab == 4 ? "brain.head.profile.fill" : "brain.head.profile")
                Text("Pensées")
            }
            .tag(4)
            .environmentObject(thoughtRecordViewModel)
        }
        .accentColor(.blue)
        .onAppear {
            // Setup tab bar appearance
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        
        // Add blur effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        appearance.backgroundEffect = blurEffect
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Reduce tab bar height slightly
        UITabBar.appearance().itemPositioning = .centered
        UITabBar.appearance().itemSpacing = 20
    }
}

#Preview {
    MainTabViewWithNewDashboard()
}