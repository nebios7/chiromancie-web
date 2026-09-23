//
//  PalmReaderApp.swift
//  PalmReader
//
//  Created by mohamed on 12/09/2026.
//

import SwiftUI

@main
struct PalmReaderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
// Vue de création d'icône AppIcon (1024x1024)
struct AppIconView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.03, blue: 0.15),
                    Color(red: 0.22, green: 0.10, blue: 0.38)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Halo lumineux central
            Circle()
                .fill(Color.purple.opacity(0.35))
                .frame(width: 600, height: 600)
                .blur(radius: 80)

            // Éléments mystiques
            VStack(spacing: 40) {
                Image(systemName: "hand.raised.sparkles.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 480, height: 480)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.84, blue: 0.4), Color.orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.orange.opacity(0.6), radius: 30)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

#Preview("Générateur d'icône App Store") {
    AppIconView()
}
