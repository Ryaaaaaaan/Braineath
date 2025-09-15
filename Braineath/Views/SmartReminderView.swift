//
//  SmartReminderView.swift
//  Braineath
//
//  Created by Ryan Zemri on 15/09/2025.
//

import SwiftUI
import UserNotifications

struct SmartReminderView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var reminderEnabled = false
    @State private var selectedTime = Date()
    @State private var reminderFrequency: ReminderFrequency = .daily
    @State private var showingPermissionRequest = false
    
    enum ReminderFrequency: String, CaseIterable {
        case daily = "Quotidien"
        case workdays = "Jours ouvrables"
        case custom = "Personnalisé"
        
        var description: String {
            switch self {
            case .daily: return "Tous les jours"
            case .workdays: return "Lundi à vendredi"
            case .custom: return "Jours sélectionnés"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.indigo.opacity(0.1),
                    Color.purple.opacity(0.05)
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
            
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Toggle
                reminderToggleSection
                
                if reminderEnabled {
                    // Time picker
                    timePickerSection
                    
                    // Frequency selector
                    frequencySection
                    
                    // Smart suggestions
                    suggestionsSection
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Rappels intelligents")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadReminderSettings()
        }
        .alert("Permissions requises", isPresented: $showingPermissionRequest) {
            Button("Paramètres") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Autorisez les notifications pour recevoir des rappels de bien-être personnalisés.")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 40))
                .foregroundColor(.indigo)
            
            Text("Rappels de bien-être")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Recevez des rappels personnalisés pour prendre soin de votre bien-être mental.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .glassBackground(.indigo)
    }
    
    private var reminderToggleSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Activer les rappels")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Notifications quotidiennes personnalisées")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $reminderEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .indigo))
                .onChange(of: reminderEnabled) { _, newValue in
                    if newValue {
                        requestNotificationPermission()
                    } else {
                        disableReminders()
                    }
                }
        }
        .padding()
        .glassBackground()
    }
    
    private var timePickerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Heure du rappel")
                .font(.headline)
                .foregroundColor(.primary)
            
            DatePicker(
                "Heure",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .onChange(of: selectedTime) { _, _ in
                scheduleReminders()
            }
        }
        .padding()
        .glassBackground()
    }
    
    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fréquence")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(ReminderFrequency.allCases, id: \.self) { frequency in
                    Button(action: {
                        reminderFrequency = frequency
                        scheduleReminders()
                        AudioManager.shared.playHapticFeedback(style: .light)
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(frequency.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text(frequency.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if reminderFrequency == frequency {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.indigo)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(reminderFrequency == frequency ? Color.indigo.opacity(0.1) : Color(.tertiarySystemBackground))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .glassBackground()
    }
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Conseils intelligents")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ReminderTip(
                    icon: "brain.head.profile.fill",
                    text: "Les rappels matinaux augmentent l'adhérence de 40%",
                    color: .blue
                )
                
                ReminderTip(
                    icon: "heart.fill",
                    text: "Des pauses régulières réduisent le stress quotidien",
                    color: .pink
                )
                
                ReminderTip(
                    icon: "leaf.fill",
                    text: "5 minutes de respiration transforment votre journée",
                    color: .green
                )
            }
        }
        .padding()
        .glassBackground(.mint)
    }
    
    private func loadReminderSettings() {
        let settings = UserDefaults.standard
        reminderEnabled = settings.bool(forKey: "smartRemindersEnabled")
        
        if let timeData = settings.data(forKey: "reminderTime"),
           let time = try? JSONDecoder().decode(Date.self, from: timeData) {
            selectedTime = time
        }
        
        if let frequencyRaw = settings.string(forKey: "reminderFrequency"),
           let frequency = ReminderFrequency(rawValue: frequencyRaw) {
            reminderFrequency = frequency
        }
    }
    
    private func saveReminderSettings() {
        let settings = UserDefaults.standard
        settings.set(reminderEnabled, forKey: "smartRemindersEnabled")
        
        if let timeData = try? JSONEncoder().encode(selectedTime) {
            settings.set(timeData, forKey: "reminderTime")
        }
        
        settings.set(reminderFrequency.rawValue, forKey: "reminderFrequency")
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    scheduleReminders()
                } else {
                    reminderEnabled = false
                    showingPermissionRequest = true
                }
            }
        }
    }
    
    private func scheduleReminders() {
        guard reminderEnabled else { return }
        
        // Remove existing reminders
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["smartReminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "Moment de bien-être"
        content.body = getSmartReminderMessage()
        content.sound = .default
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        
        switch reminderFrequency {
        case .daily:
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "smartReminder", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            
        case .workdays:
            for weekday in 2...6 { // Monday to Friday
                dateComponents.weekday = weekday
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "smartReminder_\(weekday)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
            
        case .custom:
            // For now, default to daily - could be expanded with day selection
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "smartReminder", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
        
        saveReminderSettings()
        AudioManager.shared.playNotificationHaptic(type: .success)
    }
    
    private func disableReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["smartReminder"])
        for weekday in 2...6 {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["smartReminder_\(weekday)"])
        }
        saveReminderSettings()
    }
    
    private func getSmartReminderMessage() -> String {
        let messages = [
            "Prenez 5 minutes pour respirer et vous reconnecter",
            "Comment vous sentez-vous aujourd'hui ? Notez votre humeur",
            "Un moment de gratitude peut transformer votre journée",
            "Vos pensées négatives ont-elles besoin d'être restructurées ?",
            "Une session de respiration vous attend",
            "Accordez-vous un moment de pleine conscience"
        ]
        
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Personnaliser selon l'heure
        switch hour {
        case 6...9:
            return "Commencez votre journée en douceur avec une session de bien-être"
        case 12...14:
            return "Pause déjeuner ? C'est le moment parfait pour une respiration consciente"
        case 17...19:
            return "Transition vers le soir : relâchez le stress de la journée"
        case 20...22:
            return "Préparez-vous à une nuit paisible avec quelques minutes de détente"
        default:
            return messages.randomElement() ?? messages[0]
        }
    }
}

struct ReminderTip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        SmartReminderView()
    }
}