//
//  BiometricAuthManager.swift
//  Braineath
//
//  Created by Ryan Zemri on 12/09/2025.
//

import Foundation
import LocalAuthentication
import SwiftUI

@MainActor
class BiometricAuthManager: ObservableObject {
    static let shared = BiometricAuthManager()
    
    @Published var isAuthenticated = false
    @Published var authenticationError: String?
    @Published var biometricType: LABiometryType = .none
    @Published var isAppLocked = true
    
    private let context = LAContext()
    private let userDefaults = UserDefaults.standard
    
    private init() {
        checkBiometricAvailability()
        loadLockState()
    }
    
    private func checkBiometricAvailability() {
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        } else {
            biometricType = .none
        }
    }
    
    private func loadLockState() {
        isAppLocked = userDefaults.bool(forKey: "app_lock_enabled")
    }
    
    func enableAppLock(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: "app_lock_enabled")
        isAppLocked = enabled
        
        if !enabled {
            isAuthenticated = true
        }
    }
    
    var biometricTypeDescription: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        default:
            return "Authentification biométrique"
        }
    }
    
    var biometricIcon: String {
        switch biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        default:
            return "person.crop.circle.badge.questionmark"
        }
    }
    
    var isBiometricAvailable: Bool {
        return biometricType != .none
    }
    
    func authenticateWithBiometrics() async {
        guard isBiometricAvailable else {
            authenticationError = "L'authentification biométrique n'est pas disponible sur cet appareil."
            return
        }
        
        let reason = "Utilisez \(biometricTypeDescription) pour déverrouiller Braineath"
        
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            
            if success {
                isAuthenticated = true
                authenticationError = nil
            }
        } catch let error {
            handleAuthenticationError(error)
        }
    }
    
    func authenticateWithPasscode() async {
        let reason = "Entrez votre code pour accéder à Braineath"
        
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            
            if success {
                isAuthenticated = true
                authenticationError = nil
            }
        } catch let error {
            handleAuthenticationError(error)
        }
    }
    
    private func handleAuthenticationError(_ error: Error) {
        guard let laError = error as? LAError else {
            authenticationError = "Erreur d'authentification inconnue."
            return
        }
        
        switch laError.code {
        case .userCancel:
            authenticationError = nil // L'utilisateur a annulé
        case .userFallback:
            Task {
                await authenticateWithPasscode()
            }
        case .biometryNotAvailable:
            authenticationError = "\(biometricTypeDescription) n'est pas disponible sur cet appareil."
        case .biometryNotEnrolled:
            authenticationError = "\(biometricTypeDescription) n'est pas configuré. Veuillez le configurer dans les Réglages."
        case .biometryLockout:
            authenticationError = "\(biometricTypeDescription) est temporairement verrouillé. Utilisez votre code."
            Task {
                await authenticateWithPasscode()
            }
        default:
            authenticationError = "L'authentification a échoué. Veuillez réessayer."
        }
    }
    
    func logout() {
        isAuthenticated = false
        authenticationError = nil
    }
    
    func checkAuthenticationOnAppLaunch() {
        if isAppLocked && isBiometricAvailable {
            Task {
                await authenticateWithBiometrics()
            }
        } else if !isAppLocked {
            isAuthenticated = true
        }
    }
}