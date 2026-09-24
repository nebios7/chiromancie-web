// ---- Éléments ----
const screenCapture = document.getElementById('screen-capture');
const screenLoading = document.getElementById('screen-loading');
const screenResult = document.getElementById('screen-result');

const fileInput = document.getElementById('file-input');
const captureZone = document.getElementById('capture-zone');
const previewImg = document.getElementById('preview-img');
const capturePlaceholder = document.getElementById('capture-placeholder');

const btnChoose = document.getElementById('btn-choose');
const btnAnalyze = document.getElementById('btn-analyze');
const btnRestart = document.getElementById('btn-restart');
const btnUnlock = document.getElementById('btn-unlock');
const btnRestore = document.getElementById('btn-restore');

const resultThumb = document.getElementById('result-thumb');
const trialBadge = document.getElementById('trial-badge');
const freeText = document.getElementById('free-text');
const paidText = document.getElementById('paid-text');
const paidCard = document.getElementById('paid-card');
const paywall = document.getElementById('paywall');
const errorBox = document.getElementById('error-box');

let selectedFile = null;

// ---- Gestion de l'essai gratuit (stocké localement sur l'appareil) ----
const TRIAL_KEY = 'chiromancie_free_trial_used';
function hasUsedFreeTrial() { return localStorage.getItem(TRIAL_KEY) === 'true'; }
function markFreeTrialUsed() { localStorage.setItem(TRIAL_KEY, 'true'); }

// ---- Gestion de l'achat (stocké localement — à remplacer par un vrai fournisseur de paiement, voir README) ----
const UNLOCK_KEY = 'chiromancie_unlocked';
function isUnlocked() { return localStorage.getItem(UNLOCK_KEY) === 'true'; }
function setUnlocked() { localStorage.setItem(UNLOCK_KEY, 'true'); }

// ---- Sélection de la photo ----
btnChoose.addEventListener('click', () => fileInput.click());

fileInput.addEventListener('change', () => {
  const file = fileInput.files[0];
  if (!file) return;
  selectedFile = file;
  const url = URL.createObjectURL(file);
  previewImg.src = url;
  previewImg.hidden = false;
  capturePlaceholder.hidden = true;
  btnAnalyze.hidden = false;
  hideError();
});

// ---- Lancer l'analyse ----
btnAnalyze.addEventListener('click', async () => {
  if (!selectedFile) return;
  hideError();
  show(screenLoading);

  try {
    const base64 = await fileToBase64(selectedFile);
    const res = await fetch('/api/analyze', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ imageBase64: base64, mimeType: selectedFile.type || 'image/jpeg' })
    });

    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'Une erreur est survenue.');

    renderResult(data.text, previewImg.src);
  } catch (err) {
    show(screenCapture);
    showError(err.message || 'Impossible de lire ta paume pour le moment. Réessaie.');
  }
});

// ---- Affichage du résultat ----
function renderResult(text, thumbUrl) {
  const { free, paid } = splitReading(text);

  resultThumb.src = thumbUrl;
  freeText.textContent = free;
  paidText.textContent = paid;

  const firstTime = !hasUsedFreeTrial();
  const unlocked = isUnlocked() || firstTime;

  trialBadge.hidden = !firstTime;
  paidCard.classList.toggle('locked', !unlocked);
  paywall.hidden = unlocked;

  if (firstTime) markFreeTrialUsed();

  show(screenResult);
}

// Coupe la lecture générée en une partie gratuite (Ligne de Cœur) et le reste (payant)
function splitReading(text) {
  const marker = '🧠';
  const idx = text.indexOf(marker);
  if (idx === -1) return { free: text, paid: '' };
  return { free: text.slice(0, idx).trim(), paid: text.slice(idx).trim() };
}

// ---- Débloquer / restaurer (placeholders — brancher un vrai paiement, voir README) ----
btnUnlock.addEventListener('click', () => {
  alert('Le paiement n\'est pas encore configuré. Voir le README du projet pour brancher Stripe.');
  // Une fois Stripe (ou autre) branché : après succès du paiement -> setUnlocked(); puis ré-afficher.
});

btnRestore.addEventListener('click', () => {
  if (isUnlocked()) {
    paywall.hidden = true;
    paidCard.classList.remove('locked');
  } else {
    alert('Aucun achat trouvé sur cet appareil.');
  }
});

// ---- Nouvelle lecture ----
btnRestart.addEventListener('click', () => {
  selectedFile = null;
  fileInput.value = '';
  previewImg.hidden = true;
  capturePlaceholder.hidden = false;
  btnAnalyze.hidden = true;
  hideError();
  show(screenCapture);
});

// ---- Utilitaires ----
function show(screen) {
  [screenCapture, screenLoading, screenResult].forEach(s => s.hidden = (s !== screen));
}

function showError(msg) {
  errorBox.textContent = msg;
  errorBox.hidden = false;
}
function hideError() { errorBox.hidden = true; }

function fileToBase64(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result.split(',')[1]);
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}
