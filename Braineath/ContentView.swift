//
//  ContentView.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var authManager = BiometricAuthManager.shared
    @StateObject private var profileManager = UserProfileManager.shared

    var body: some View {
        ZStack {
            if authManager.isAppLocked && !authManager.isAuthenticated {
                // Écran d'authentification
                BiometricAuthView()
            } else if !profileManager.isOnboardingComplete {
                // Écran d'onboarding
                OnboardingView()
            } else {
                // Interface principale de l'application avec nouvelle dashboard
                MainTabViewWithNewDashboard()
            }
        }
        .onAppear {
            authManager.checkAuthenticationOnAppLaunch()
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
