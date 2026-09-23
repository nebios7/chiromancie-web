import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasUsedFreeTrial") private var hasUsedFreeTrial = false
    @State private var restoreMessage: String?
    
    var body: some View {
        NavigationStack {
            List {
                // Section Achats
                Section(header: Text("Achats & Réinitialisation")) {
                    Button(action: restorePurchases) {
                        HStack {
                            Label("Restaurer mes achats", systemImage: "arrow.clockwise.circle")
                            Spacer()
                        }
                    }
                    .foregroundColor(.purple)
                    
                    if let msg = restoreMessage {
                        Text(msg)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // Section Informations Légales (Obligatoire pour l'App Store)
                Section(header: Text("À propos & Légal")) {
                    Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                        Label("Conditions d'utilisation (EULA)", systemImage: "doc.text")
                    }
                    
                    Link(destination: URL(string: "https://www.termsfeed.com/live/2c1e268a-50bc-48f1-9844-b3d5fb4a5cdf")!) { // Remplace par ton lien de politique de confidentialité
                        Label("Politique de confidentialité", systemImage: "hand.raised.slash")
                    }
                }
                
                // Section Application
                Section(header: Text("Application")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Identifiant Produit")
                        Spacer()
                        Text("Apple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Paramètres ⚙️")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func restorePurchases() {
        Task {
            do {
                try await AppStore.sync()
                await MainActor.run {
                    restoreMessage = "Synchronisation effectuée."
                }
            } catch {
                await MainActor.run {
                    restoreMessage = "Erreur de restauration : \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
