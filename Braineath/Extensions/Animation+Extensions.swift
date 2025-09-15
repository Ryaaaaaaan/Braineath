//
//  Animation+Extensions.swift
//  Braineath
//
//  Created by Ryan Zemri on 15/09/2025.
//

import SwiftUI

extension Animation {
    // Apple-style spring animations
    static let appleSpring = Animation.spring(response: 0.55, dampingFraction: 0.825)
    static let appleSpringSlower = Animation.spring(response: 0.75, dampingFraction: 0.85)
    static let appleSpringFaster = Animation.spring(response: 0.4, dampingFraction: 0.8)
    
    // Smooth ease animations
    static let appleEase = Animation.easeInOut(duration: 0.35)
    static let appleEaseSlower = Animation.easeInOut(duration: 0.5)
    static let appleEaseFaster = Animation.easeInOut(duration: 0.25)
    
    // Breathing animation
    static let breathingIn = Animation.easeInOut(duration: 4.0)
    static let breathingOut = Animation.easeInOut(duration: 6.0)
    static let breathingHold = Animation.easeInOut(duration: 2.0)
    
    // Interactive animations
    static let buttonPress = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let cardEntry = Animation.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)
}

// MARK: - View Modifiers for Apple-style animations
struct AppleStyleButtonModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.buttonPress, value: isPressed)
            .onTapGesture {
                AudioManager.shared.playHapticFeedback(style: .light)
            }
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

struct CardEntryModifier: ViewModifier {
    @State private var hasAppeared = false
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 20)
            .animation(.cardEntry.delay(delay), value: hasAppeared)
            .onAppear {
                hasAppeared = true
            }
    }
}

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    let color: Color
    let intensity: Double
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: isPulsing ? 3 : 0)
                    .scaleEffect(isPulsing ? 1.1 : 1.0)
                    .opacity(isPulsing ? 0 : intensity)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                        value: isPulsing
                    )
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - View Extensions
extension View {
    func appleStyleButton() -> some View {
        modifier(AppleStyleButtonModifier())
    }
    
    func cardEntry(delay: Double = 0) -> some View {
        modifier(CardEntryModifier(delay: delay))
    }
    
    func pulse(color: Color = .blue, intensity: Double = 0.3) -> some View {
        modifier(PulseModifier(color: color, intensity: intensity))
    }
    
    func glassBackground(_ color: Color = .white, opacity: Double = 0.1) -> some View {
        background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(opacity))
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    func breathingScale(isActive: Bool, scale: Double = 1.2) -> some View {
        scaleEffect(isActive ? scale : 1.0)
            .animation(.breathingIn.repeatForever(autoreverses: true), value: isActive)
    }
}