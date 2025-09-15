//
//  NotificationManager.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
            
            if granted {
                self.scheduleDefaultReminders()
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleDefaultReminders() {
        // Rappel du matin pour définir une intention
        scheduleDailyNotification(
            identifier: "morning-intention",
            title: "🌅 Nouvelle journée",
            body: "Prenez un moment pour définir votre intention du jour",
            hour: 8,
            minute: 0
        )
        
        // Rappel de l'après-midi pour une pause respiration
        scheduleDailyNotification(
            identifier: "afternoon-breathing",
            title: "🫁 Pause respiration",
            body: "Quelques minutes de respiration consciente pour recentrer votre énergie",
            hour: 14,
            minute: 30
        )
        
        // Rappel du soir pour le journal émotionnel
        scheduleDailyNotification(
            identifier: "evening-journal",
            title: "📝 Reflet de la journée",
            body: "Comment vous êtes-vous senti aujourd'hui ? Prenez note de vos émotions",
            hour: 20,
            minute: 0
        )
    }
    
    private func scheduleDailyNotification(identifier: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "BRAINEATH_REMINDER"
        
        // Add app icon to notification
        if let iconAttachment = createAppIconAttachment() {
            content.attachments = [iconAttachment]
        }
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification \(identifier): \(error)")
            }
        }
    }
    
    func scheduleEmergencyFollowUp() {
        let content = UNMutableNotificationContent()
        content.title = "💙 Comment allez-vous ?"
        content.body = "Prenez un moment pour évaluer comment vous vous sentez maintenant"
        content.sound = .default
        content.categoryIdentifier = "EMERGENCY_FOLLOWUP"
        
        // Add app icon to notification
        if let iconAttachment = createAppIconAttachment() {
            content.attachments = [iconAttachment]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false) // 1 heure après
        let request = UNNotificationRequest(identifier: "emergency-followup-\(UUID())", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleBreathingReminder(after minutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🧘‍♀️ Moment respiration"
        content.body = "Il est temps de reprendre quelques respirations conscientes"
        content.sound = .default
        
        // Add app icon to notification
        if let iconAttachment = createAppIconAttachment() {
            content.attachments = [iconAttachment]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutes * 60), repeats: false)
        let request = UNNotificationRequest(identifier: "breathing-reminder-\(UUID())", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    private func createAppIconAttachment() -> UNNotificationAttachment? {
        // Try to get the app icon from bundle first
        var image: UIImage?
        
        // Method 1: Try to get from app icon asset
        if let bundleIconFiles = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = bundleIconFiles["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let iconFileName = iconFiles.last {
            image = UIImage(named: iconFileName)
        }
        
        // Method 2: Try direct asset lookup
        if image == nil {
            image = UIImage(named: "Icon-iOS-Default-1024x1024@1x")
        }
        
        // Method 3: Try to get from app icon (may not work)
        if image == nil {
            image = UIImage(named: "AppIcon")
        }
        
        // Method 4: Create a simple placeholder if all fails
        if image == nil {
            // Create a simple blue circle with brain icon as fallback
            let size = CGSize(width: 64, height: 64)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(UIColor.systemBlue.cgColor)
            context?.fillEllipse(in: CGRect(origin: .zero, size: size))
            
            // Add brain icon
            let brainIcon = UIImage(systemName: "brain.head.profile.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            brainIcon?.draw(in: CGRect(x: 16, y: 16, width: 32, height: 32))
            
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        guard let finalImage = image else {
            print("Failed to create app icon for notification")
            return nil
        }
        
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileURL = tmpSubFolderURL.appendingPathComponent("appicon.png")
            
            guard let imageData = finalImage.pngData() else { 
                print("Failed to convert image to PNG data")
                return nil 
            }
            try imageData.write(to: imageFileURL)
            
            let attachment = try UNNotificationAttachment(identifier: "appicon", url: imageFileURL, options: nil)
            return attachment
        } catch {
            print("Error creating notification attachment: \(error)")
            return nil
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let identifier = response.notification.request.identifier
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // L'utilisateur a tapé sur la notification
            handleNotificationTap(identifier: identifier)
        default:
            break
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Afficher la notification même si l'app est au premier plan
        completionHandler([.banner, .badge, .sound])
    }
    
    private func handleNotificationTap(identifier: String) {
        // Logique pour naviguer vers la bonne section de l'app
        if identifier.contains("morning-intention") {
            // Naviguer vers les intentions
        } else if identifier.contains("afternoon-breathing") {
            // Naviguer vers les exercices de respiration
        } else if identifier.contains("evening-journal") {
            // Naviguer vers le journal émotionnel
        } else if identifier.contains("emergency-followup") {
            // Naviguer vers le suivi d'urgence
        }
    }
}