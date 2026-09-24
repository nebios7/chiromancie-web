# Chiromancie — Web App

Version web de l'app (remplace la soumission App Store refusée). Fonctionne dans n'importe quel navigateur ; peut être ajoutée à l'écran d'accueil iOS/Android pour ressembler à une app native.

## ⚠️ À faire avant tout : révoque l'ancienne clé API

La clé Gemini qui était codée en dur dans le projet Swift (`AIzaSyBZd1Qy...`) a été exposée. Va sur [Google AI Studio](https://aistudio.google.com/app/apikey) et :
1. Supprime/révoque cette clé.
2. Crée une **nouvelle** clé — c'est celle-ci que tu utiliseras ci-dessous (jamais dans le code, uniquement dans les variables d'environnement Vercel).

## Déploiement (10 minutes)

### 1. Mettre le code sur GitHub
1. Sur github.com/nebios7, crée un nouveau repo, par exemple `chiromancie-web`.
2. Décompresse ce zip, puis dans l'onglet **"Add file → Upload files"** du repo, glisse-dépose tous les fichiers (garde la structure, notamment le dossier `api/`).
3. Commit.

### 2. Déployer sur Vercel
1. Va sur [vercel.com](https://vercel.com) → connecte-toi avec ton compte GitHub.
2. **Add New → Project** → sélectionne le repo `chiromancie-web`.
3. Avant de cliquer "Deploy", ouvre **Environment Variables** et ajoute :
   - Nom : `GEMINI_API_KEY`
   - Valeur : ta nouvelle clé Gemini
4. Clique **Deploy**.
5. Tu obtiens un lien du type `chiromancie-web.vercel.app` — ton site est en ligne.

### 3. (Optionnel) Nom de domaine personnalisé
Dans Vercel → Settings → Domains, tu peux relier un domaine acheté ailleurs (ex: `chiromancie.fr`).

## Ajouter l'app à l'écran d'accueil (iOS)
Sur iPhone/iPad, ouvrir le lien dans Safari → bouton Partager → "Sur l'écran d'accueil". L'icône s'ouvre en plein écran, sans barre d'adresse.

## Paiement — à finaliser

Le bouton "Débloquer — 1,99 €" est actuellement un **placeholder** : il n'encaisse pas de vrai paiement. Pour un vrai paiement en ligne, l'option la plus simple est **Stripe Checkout** :
1. Crée un compte sur [stripe.com](https://stripe.com).
2. Crée un "Payment Link" à 1,99 € dans le dashboard Stripe (aucun code requis pour une première version).
3. Remplace l'action du bouton `btnUnlock` dans `script.js` par une redirection vers ce lien.
4. Pour débloquer automatiquement après paiement, il faut une page de retour + webhook Stripe (je peux t'aider à le mettre en place si besoin).

## Structure du projet

```
index.html      → page principale
style.css       → styles
script.js       → logique (capture photo, appel API, paywall, essai gratuit)
api/analyze.js  → fonction serveur qui appelle Gemini (garde la clé API secrète)
vercel.json     → config Vercel
```

## Tester en local (optionnel)

```bash
npm install -g vercel
vercel dev
```
Puis ouvrir `http://localhost:3000`.
