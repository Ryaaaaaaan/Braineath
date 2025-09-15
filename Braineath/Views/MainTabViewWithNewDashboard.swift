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
            
            // Daily Wellness Tracker
            NavigationView {
                DailyWellnessView()
            }
            .tabItem {
                Image(systemName: selectedTab == 3 ? "chart.line.uptrend.xyaxis.circle.fill" : "chart.line.uptrend.xyaxis.circle")
                Text("Bien-être")
            }
            .tag(3)
            
            // Secure Private Space (Thoughts + Private merged with biometric)
            SecurePrivateSpaceView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "lock.shield.fill" : "lock.shield")
                    Text("Privé")
                }
                .tag(4)
                .environmentObject(thoughtRecordViewModel)
                .environmentObject(gratitudeViewModel)
                .environmentObject(intentionsViewModel)
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
        
        // Modern translucent background with blur
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        // Selected tab styling
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Normal tab styling
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
        ]
        
        // Apply to all tab bar states
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Enhanced visual feedback
        UITabBar.appearance().itemPositioning = .centered
        UITabBar.appearance().itemSpacing = 8
        UITabBar.appearance().tintColor = UIColor.systemBlue
        UITabBar.appearance().unselectedItemTintColor = UIColor.secondaryLabel
    }
}

#Preview {
    MainTabViewWithNewDashboard()
}