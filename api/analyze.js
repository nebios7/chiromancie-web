// Fonction serveur (Vercel Serverless Function).
// Tourne côté serveur : la clé API n'est JAMAIS envoyée au navigateur.
// Configure GEMINI_API_KEY dans Vercel → Settings → Environment Variables.

const PROMPT = `Tu es un expert mystique et bienveillant en chiromancie. Analyse l'image de la main fournie et donne une lecture détaillée du trajet de vie en français.

Structure impérativement la réponse avec ces titres exacts :
1. ❤️ Ligne de Cœur (émotions, relations)
2. 🧠 Ligne de Tête (esprit, décisions)
3. 🌱 Ligne de Vie (vitalité, parcours)
4. ✨ Ligne de Destinée (accomplissement)
5. 🔮 Synthèse du Trajet de Vie

Sois inspirant, poétique et constructif. Ne fais aucune prédiction médicale ou néfaste.`;

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Méthode non autorisée.' });
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    return res.status(500).json({ error: 'Clé API manquante côté serveur (variable GEMINI_API_KEY).' });
  }

  const { imageBase64, mimeType } = req.body || {};
  if (!imageBase64) {
    return res.status(400).json({ error: 'Aucune image reçue.' });
  }

  try {
    const model = 'gemini-2.5-flash';
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

    const payload = {
      contents: [
        {
          parts: [
            { text: PROMPT },
            { inline_data: { mime_type: mimeType || 'image/jpeg', data: imageBase64 } }
          ]
        }
      ]
    };

    const geminiRes = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    const data = await geminiRes.json();

    const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!text) {
      const message = data?.error?.message || 'Réponse inattendue du service de lecture.';
      return res.status(502).json({ error: message });
    }

    return res.status(200).json({ text });
  } catch (err) {
    return res.status(500).json({ error: 'Erreur réseau lors de l\'analyse.' });
  }
}
