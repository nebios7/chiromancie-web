import SwiftUI
import StoreKit

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var isShowingCamera = false
    @State private var readingResult: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // État du verrouillage et de l'achat
    @State private var isUnlocked = false
    @State private var isPurchasing = false
    @State private var isFirstScanEver = false
    @State private var isShowingSettings = false
    
    // Identifiants configurés pour ton application
    private let productID = "mlseclab.PalmReader"
    private let geminiAPIKey = "AIzaSyBZd1QypXKrtA3aE7VAHMWBSIgYSNjbme0"
    private let freeTrialKey = "hasUsedFreeTrial"

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                // AFFICHAGE 1 : Résultat de l'analyse
                if !readingResult.isEmpty {
                    let parsedContent = splitReadingResult(readingResult)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            if let img = selectedImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                            }
                            VStack(alignment: .leading) {
                                Text("Lecture de ta paume 🔮")
                                    .font(.title3.bold())
                                    .foregroundColor(.purple)
                                
                                if isFirstScanEver {
                                    Text("🎁 Première analyse offerte !")
                                        .font(.caption.bold())
                                        .foregroundColor(.green)
                                }
                            }
                            Spacer()
                        }
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                // Partie 1 : Toujours visible (Ligne de Cœur)
                                Text(parsedContent.free)
                                    .font(.system(size: 17, weight: .regular, design: .serif))
                                    .lineSpacing(6)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.purple.opacity(0.12))
                                    .cornerRadius(16)
                                
                                // Partie 2 à 5 : Accessible sur le 1er scan ou après paiement
                                ZStack {
                                    VStack(alignment: .leading) {
                                        Text(parsedContent.paid)
                                            .font(.system(size: 17, weight: .regular, design: .serif))
                                            .lineSpacing(6)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.purple.opacity(0.12))
                                            .cornerRadius(16)
                                    }
                                    .blur(radius: isUnlocked ? 0 : 10)
                                    .disabled(!isUnlocked)
                                    
                                    // Paywall affiché uniquement après l'essai gratuit
                                    if !isUnlocked {
                                        VStack(spacing: 14) {
                                            Image(systemName: "lock.fill")
                                                .font(.system(size: 36))
                                                .foregroundColor(.purple)
                                            
                                            Text("Débloquer la suite de l'analyse")
                                                .font(.headline.bold())
                                            
                                            Text("Ton essai gratuit est consommé. Accède aux Lignes de Tête, Vie, Destinée et à la Synthèse complète.")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal)
                                            
                                            Button(action: purchaseAnalysis) {
                                                if isPurchasing {
                                                    ProgressView()
                                                        .tint(.white)
                                                } else {
                                                    Text("DÉBLOQUER CETTE ANALYSE — 1,99 €")
                                                        .font(.headline.bold())
                                                        .foregroundColor(.white)
                                                        .padding()
                                                        .frame(maxWidth: .infinity)
                                                        .background(Color.purple)
                                                        .cornerRadius(12)
                                                }
                                            }
                                            .disabled(isPurchasing)
                                            .padding(.horizontal)
                                            
                                            Button("Restaurer les achats") {
                                                restorePurchases()
                                            }
                                            .font(.caption)
                                            .foregroundColor(.purple)
                                            .padding(.top, 4)
                                        }
                                        .padding(.vertical, 24)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(20)
                                        .shadow(color: Color.black.opacity(0.15), radius: 10)
                                        .padding(.horizontal, 8)
                                    }
                                }
                            }
                        }
                        
                        Button(action: {
                            selectedImage = nil
                            readingResult = ""
                            errorMessage = nil
                            isUnlocked = false
                        }) {
                            Label("Faire une nouvelle analyse", systemImage: "arrow.triangle.2.circlepath")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(14)
                        }
                    }
                }
                // AFFICHAGE 2 : Capture de photo
                else {
                    VStack(spacing: 20) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 240)
                                .cornerRadius(16)
                                .shadow(radius: 4)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 260)
                                .overlay {
                                    VStack(spacing: 12) {
                                        Image(systemName: "hand.raised.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.purple)
                                        Text("Prends ta main en photo")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                        }

                        Button(action: {
                            isShowingCamera = true
                        }) {
                            Label(selectedImage == nil ? "Ouvrir l'appareil photo" : "Reprendre une photo", systemImage: "camera.fill")
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(14)
                        }

                        if selectedImage != nil {
                            Button(action: startAnalysis) {
                                if isLoading {
                                    HStack(spacing: 10) {
                                        ProgressView()
                                            .tint(.white)
                                        Text("Analyse en cours...")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                } else {
                                    Text(hasUsedFreeTrial() ? "RÉVÉLER MON TRAJET DE VIE" : "TESTER GRATUITEMENT MON ANALYSE")
                                        .font(.headline.bold())
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(hasUsedFreeTrial() ? Color.black : Color.green)
                            .cornerRadius(14)
                            .disabled(isLoading)
                        }

                        if let err = errorMessage {
                            Text(err)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .navigationTitle("Lecteur de Paume 🔮")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $isShowingCamera) {
                CameraPicker(image: $selectedImage)
            }
        }
    }

    private func hasUsedFreeTrial() -> Bool {
        return UserDefaults.standard.bool(forKey: freeTrialKey)
    }

    private func markFreeTrialAsUsed() {
        UserDefaults.standard.set(true, forKey: freeTrialKey)
    }

    private func startAnalysis() {
        isLoading = true
        errorMessage = nil
        
        if !hasUsedFreeTrial() {
            isUnlocked = true
            isFirstScanEver = true
            markFreeTrialAsUsed()
        } else {
            isUnlocked = false
            isFirstScanEver = false
        }
        
        fetchAvailableModel { modelName in
            guard let modelName = modelName else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Impossible de contacter l'IA."
                }
                return
            }
            self.sendPalmAnalysisRequest(usingModel: modelName)
        }
    }

    /// Découpe intelligente et sécurisée du texte d'analyse pour le paywall
    private func splitReadingResult(_ text: String) -> (free: String, paid: String) {
        // Recherche souple de la section 2 (Ligne de Tête) avec Regex pour éviter les failles
        let regexPattern = #"(?i)(?:^|\n)\s*(?:###?\s*)?2[\.\-\)]\s*🧠"#
        if let range = text.range(of: regexPattern, options: .regularExpression) {
            let freePart = String(text[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            let paidPart = String(text[range.lowerBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            return (freePart, paidPart)
        }
        
        // Fallback si la structure avec emoji "2. 🧠" a varié
        let paragraphs = text.components(separatedBy: "\n\n")
        if paragraphs.count > 1 {
            let freePart = paragraphs[0]
            let paidPart = paragraphs.dropFirst().joined(separator: "\n\n")
            return (freePart, paidPart)
        }
        
        // Fallback par défaut
        return (text, "2. 🧠 Ligne de Tête...\n3. 🌱 Ligne de Vie...\n4. ✨ Ligne de Destinée...\n5. 🔮 Synthèse du Trajet de Vie...")
    }

    private func purchaseAnalysis() {
        isPurchasing = true
        
        Task {
            do {
                let products = try await Product.products(for: [productID])
                if let product = products.first {
                    let result = try await product.purchase()
                    switch result {
                    case .success(let verification):
                        switch verification {
                        case .verified(let transaction):
                            await transaction.finish()
                            await MainActor.run {
                                self.isUnlocked = true
                                self.isPurchasing = false
                            }
                        case .unverified:
                            await MainActor.run {
                                self.isPurchasing = false
                                self.errorMessage = "Échec de vérification de l'achat."
                            }
                        }
                    case .userCancelled, .pending:
                        await MainActor.run { self.isPurchasing = false }
                    @unknown default:
                        await MainActor.run { self.isPurchasing = false }
                    }
                } else {
                    // Pour le test local si pas de StoreKit configuration file
                    await MainActor.run {
                        self.isUnlocked = true
                        self.isPurchasing = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isPurchasing = false
                    self.errorMessage = "Erreur d'achat : \(error.localizedDescription)"
                }
            }
        }
    }

    private func restorePurchases() {
        Task {
            try? await AppStore.sync()
        }
    }

    private func fetchAvailableModel(completion: @escaping (String?) -> Void) {
        let listUrlString = "https://generativelanguage.googleapis.com/v1beta/models?key=\(geminiAPIKey)"
        guard let url = URL(string: listUrlString) else { completion(nil); return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let models = json["models"] as? [[String: Any]] else {
                completion(nil)
                return
            }
            
            let targetModel = models.first { dict in
                guard let name = dict["name"] as? String,
                      let methods = dict["supportedGenerationMethods"] as? [String] else { return false }
                return methods.contains("generateContent") && (name.contains("flash") || name.contains("pro"))
            }
            
            if let fullName = targetModel?["name"] as? String {
                completion(fullName.replacingOccurrences(of: "models/", with: ""))
            } else {
                completion(nil)
            }
        }.resume()
    }

    private func sendPalmAnalysisRequest(usingModel modelName: String) {
        guard let originalImage = selectedImage,
              let resizedImage = originalImage.resizedTo(maxDimension: 800),
              let imageData = resizedImage.jpegData(compressionQuality: 0.6)?.base64EncodedString() else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Impossible de traiter la photo."
            }
            return
        }

        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent?key=\(geminiAPIKey)"
        guard let url = URL(string: urlString) else { return }

        let promptText = """
        Tu es un expert mystique et bienveillant en chiromancie. Analyse l'image de la main fournie et donne une lecture détaillée du trajet de vie en français.
        
        Structure impérativement la réponse avec ces titres exacts :
        1. ❤️ Ligne de Cœur (émotions, relations)
        2. 🧠 Ligne de Tête (esprit, décisions)
        3. 🌱 Ligne de Vie (vitalité, parcours)
        4. ✨ Ligne de Destinée (accomplissement)
        5. 🔮 Synthèse du Trajet de Vie
        
        Sois inspirant, poétique et constructif. Ne fais aucune prédiction médicale ou néfaste.
        """

        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": promptText],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": imageData
                            ]
                        ]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Erreur réseau : \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "Aucune réponse reçue du serveur."
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let candidates = json["candidates"] as? [[String: Any]],
                           let firstCandidate = candidates.first,
                           let content = firstCandidate["content"] as? [String: Any],
                           let parts = content["parts"] as? [[String: Any]],
                           let firstPart = parts.first,
                           let text = firstPart["text"] as? String {
                            self.readingResult = text
                        } else if let errorDict = json["error"] as? [String: Any],
                                  let message = errorDict["message"] as? String {
                            self.errorMessage = "Erreur au serveur : \(message)"
                        } else {
                            self.errorMessage = "Format de réponse non reconnu."
                        }
                    }
                } catch {
                    self.errorMessage = "Erreur d'analyse des données."
                }
            }
        }.resume()
    }
}

extension UIImage {
    func resizedTo(maxDimension: CGFloat) -> UIImage? {
        let aspectRatio = size.width / size.height
        var newSize: CGSize
        if aspectRatio > 1 {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
