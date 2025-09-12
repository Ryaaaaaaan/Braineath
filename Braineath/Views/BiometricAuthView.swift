//
//  BiometricAuthView.swift
//  Braineath
//
//  Created by Ryan Zemri on 12/09/2025.
//

import SwiftUI

struct BiometricAuthView: View {
    @StateObject private var authManager = BiometricAuthManager.shared
    @State private var isAuthenticating = false
    
    var body: some View {
        ZStack {
            // Background dégradé
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color.blue.opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo et titre
                VStack(spacing: 20) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Braineath")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Votre bien-être mental en sécurité")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Section d'authentification
                VStack(spacing: 24) {
                    if authManager.isBiometricAvailable {
                        // Bouton d'authentification biométrique
                        Button(action: {
                            authenticateWithBiometrics()
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: authManager.biometricIcon)
                                    .font(.title2)
                                
                                Text("Déverrouiller avec \(authManager.biometricTypeDescription)")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isAuthenticating)
                        .opacity(isAuthenticating ? 0.7 : 1.0)
                    }
                    
                    // Bouton d'authentification par code
                    Button(action: {
                        authenticateWithPasscode()
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "key.fill")
                                .font(.title3)
                            
                            Text("Utiliser le code")
                                .font(.subheadline)
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemBackground))
                                )
                        )
                    }
                    .disabled(isAuthenticating)
                    .opacity(isAuthenticating ? 0.7 : 1.0)
                    
                    // Message d'erreur
                    if let error = authManager.authenticationError {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Footer
                Text("Vos données restent privées et sécurisées")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
            }
            
            // Indicateur de chargement
            if isAuthenticating {
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            }
        }
    }
    
    private func authenticateWithBiometrics() {
        isAuthenticating = true
        
        Task {
            await authManager.authenticateWithBiometrics()
            isAuthenticating = false
        }
    }
    
    private func authenticateWithPasscode() {
        isAuthenticating = true
        
        Task {
            await authManager.authenticateWithPasscode()
            isAuthenticating = false
        }
    }
}

#Preview {
    BiometricAuthView()
}