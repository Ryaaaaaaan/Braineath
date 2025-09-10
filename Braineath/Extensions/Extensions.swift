//
//  Extensions.swift
//  Braineath
//
//  Created by Ryan Zemri on 10/09/2025.
//

import Foundation
import SwiftUI

// MARK: - Date Extensions
extension Date {
    func isInSameWeek(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    
    func isInSameDay(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: date)
    }
    
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay()) ?? self
    }
    
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: self)
    }
    
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions
extension String {
    func truncated(toLength length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        } else {
            return self
        }
    }
    
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var wordCount: Int {
        let words = components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static func dynamicColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
    
    // Couleurs personnalisées pour l'app
    static let braineathBlue = Color(hex: "#4A90E2")
    static let braineathPurple = Color(hex: "#9B59B6")
    static let braineathGreen = Color(hex: "#2ECC71")
    static let braineathOrange = Color(hex: "#E67E22")
    static let braineathPink = Color(hex: "#E91E63")
    
    // Couleurs d'émotions
    static let emotionJoy = Color(hex: "#FFD700")
    static let emotionCalm = Color(hex: "#87CEEB")
    static let emotionEnergy = Color(hex: "#FF6347")
    static let emotionAnxiety = Color(hex: "#FF4500")
    static let emotionSadness = Color(hex: "#4169E1")
}

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func cardStyle() -> some View {
        self
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    func glassEffect() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
    
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
    
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Custom Shapes
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Custom Modifiers
struct ShimmerModifier: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.4),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: isAnimating ? 300 : -300)
                .animation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            )
            .onAppear {
                isAnimating = true
            }
            .clipped()
    }
}

// MARK: - Haptic Feedback Helper
struct HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Double Extensions pour les animations
extension Double {
    func toRadians() -> Double {
        return self * .pi / 180
    }
    
    func toDegrees() -> Double {
        return self * 180 / .pi
    }
}

// MARK: - Array Extensions
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

// MARK: - UserDefaults Extensions pour les préférences
extension UserDefaults {
    private enum Keys {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let preferredTheme = "preferredTheme"
        static let notificationsEnabled = "notificationsEnabled"
        static let onboardingCompleted = "onboardingCompleted"
        static let lastBackupDate = "lastBackupDate"
    }
    
    var hasLaunchedBefore: Bool {
        get { bool(forKey: Keys.hasLaunchedBefore) }
        set { set(newValue, forKey: Keys.hasLaunchedBefore) }
    }
    
    var preferredTheme: String {
        get { string(forKey: Keys.preferredTheme) ?? "adaptive" }
        set { set(newValue, forKey: Keys.preferredTheme) }
    }
    
    var notificationsEnabled: Bool {
        get { bool(forKey: Keys.notificationsEnabled) }
        set { set(newValue, forKey: Keys.notificationsEnabled) }
    }
    
    var onboardingCompleted: Bool {
        get { bool(forKey: Keys.onboardingCompleted) }
        set { set(newValue, forKey: Keys.onboardingCompleted) }
    }
    
    var lastBackupDate: Date? {
        get { object(forKey: Keys.lastBackupDate) as? Date }
        set { set(newValue, forKey: Keys.lastBackupDate) }
    }
}

// MARK: - Binding Extensions
extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

// MARK: - Animation Extensions
extension Animation {
    static let gentleBounce = Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
    static let gentleEaseInOut = Animation.easeInOut(duration: 0.3)
    static let smoothSpring = Animation.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0)
}

// MARK: - Environment Values personnalisés
struct BraineathThemeKey: EnvironmentKey {
    static let defaultValue: String = "adaptive"
}

extension EnvironmentValues {
    var braineathTheme: String {
        get { self[BraineathThemeKey.self] }
        set { self[BraineathThemeKey.self] = newValue }
    }
}