//
//  AppIconView.swift
//  PalmReader
//
//  Created by mohamed on 13/09/2026.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

// MARK: - Design de l'icône de l'application (1024x1024 px)
struct AppIconDesignView: View {
    var body: some View {
        ZStack {
            // 1. Fond dégradé cosmique sombre
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.03, blue: 0.15),
                    Color(red: 0.18, green: 0.08, blue: 0.32)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 2. Halos de lumière
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.purple.opacity(0.5),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 400
                    )
                )
                .frame(width: 800, height: 800)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.orange.opacity(0.25),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)

            // 3. Cadre géométrique sacré
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.6),
                            Color.purple.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 6
                )
                .frame(width: 620, height: 620)
                .shadow(color: Color.orange.opacity(0.3), radius: 20)

            // 4. Élément visuel principal : Main mystique
            VStack(spacing: 0) {
                Image(systemName: "hand.raised.sparkles.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 440, height: 440)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.88, blue: 0.45),
                                Color(red: 0.95, green: 0.55, blue: 0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.orange.opacity(0.5), radius: 30)
            }
            
            // 5. Étoiles périphériques
            VStack {
                HStack {
                    Image(systemName: "sparkle")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                        .shadow(color: .orange, radius: 10)
                        .padding(.leading, 180)
                        .padding(.top, 180)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "star.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.8))
                        .shadow(color: .orange, radius: 10)
                        .padding(.trailing, 200)
                        .padding(.bottom, 200)
                }
            }
        }
        .frame(width: 1024, height: 1024)
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Exportation de l'image
#if os(macOS)
@MainActor
func exportIconToDesktop() {
    let iconView = AppIconDesignView()
    let renderer = ImageRenderer(content: iconView)
    renderer.proposedSize = ProposedViewSize(width: 1024, height: 1024)
    
    if let nsImage = renderer.nsImage {
        guard let tiffData = nsImage.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            print("❌ Échec de la conversion en PNG")
            return
        }
        
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let destinationURL = desktopURL.appendingPathComponent("AppIcon_PalmReader_1024.png")
        
        do {
            try pngData.write(to: destinationURL)
            print("✅ SUCCÈS : L'icône 1024x1024 a été enregistrée sur le Bureau : \(destinationURL.path)")
        } catch {
            print("❌ Erreur lors de la sauvegarde : \(error.localizedDescription)")
        }
    }
}
#endif

// MARK: - Aperçu Xcode avec appel automatique
#Preview("Icône App Store (1024x1024)") {
    AppIconDesignView()
        .frame(width: 400, height: 400)
        .onAppear {
            #if os(macOS)
            exportIconToDesktop()
            #endif
        }
}
