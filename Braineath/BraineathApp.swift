//
//  BraineathApp.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import SwiftUI
import UserNotifications

@main
struct BraineathApp: App {
    let dataManager = DataManager.shared
    let notificationManager = NotificationManager.shared
    let audioManager = AudioManager.shared
    
    init() {
        // Configuration des notifications
        UNUserNotificationCenter.current().delegate = notificationManager
        
        // Demander les permissions de notification
        notificationManager.requestAuthorization()
        
        // Précharger les sons
        audioManager.preloadSounds()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, dataManager.context)
                .environmentObject(notificationManager)
                .environmentObject(audioManager)
        }
    }
}
