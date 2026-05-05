# 📱 Plan de Tests et Déploiement Mobile — MonApp

Ce document détaille toute la chaîne CI/CD pour l'application mobile React Native **MonApp**.

---

## 📋 Table des Matières

1. [Configuration de l'Environnement](#-configuration-de-lenvironnement)
2. [Types de Tests](#-types-de-tests)
3. [Déploiement avec Fastlane](#-déploiement-avec-fastlane)
4. [CI/CD avec GitHub Actions](#-cicd-avec-github-actions)
5. [Script Local de Déploiement](#-script-local-de-déploiement)
6. [Checklist de Suivi](#-checklist-de-suivi)

---

## ⚙️ Configuration de l'Environnement

### Variables d'Environnement Android

Sur **macOS/Linux**, ajoutez à votre `.bashrc` ou `.zshrc`:

```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export GRADLE_OPTS=-Xmx4096m
```

Sur **Windows** (PowerShell):

```powershell
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
$env:PATH = "$env:PATH;$env:ANDROID_HOME\emulator;$env:ANDROID_HOME\platform-tools"
$env:GRADLE_OPTS = "-Xmx4096m"
```

### Installation des Dépendances

```bash
# Installation des dépendances du projet
npm install

# Installation globale de Fastlane
npm install -g fastlane
```

---

## 🧪 Types de Tests

### 1. Tests Unitaires (Jest)

**Description:** Testent le comportement des composants et fonctions de manière isolée.

**Fichiers de test:** `__tests__/**/*.test.tsx`

**Commandes:**

```bash
# Lancer les tests
npm test

# Lancer les tests avec rapport de couverture
npm run test:coverage

# Lancer les tests en mode watch
npm test -- --watch
```

**Exemple de test (`__tests__/App.test.tsx`):**

```typescript
describe('App Component', () => {
  it('affiche l\'écran principal correctement', async () => {
    const { getByText } = render(<App />);
    expect(getByText(/Welcome to React Native/i)).toBeTruthy();
  });
});
```

### 2. Tests E2E (Detox)

**Description:** Testent le comportement complet de l'application comme un utilisateur réel le ferait.

**Fichiers de test:** `e2e/**/*.test.js`

**Prérequis:**
- Émulateur Android en cours d'exécution avec le nom `Pixel_3a_API_30_x86` (ou modifier `.detoxrc.js`)

**Commandes:**

```bash
# Build l'APK de test pour Detox
npm run detox:build

# Exécuter les tests E2E
npm run detox:test

# Ou utiliser directement
npx detox build --configuration android.emu
npx detox test --configuration android.emu
```

**Configuration Detox (`.detoxrc.js`):**
- Les configurations Android sont pré-configurées
- Modifier l'AVD (`avdName`) si vous utilisez un émulateur différent

### 3. Tests UI Android (Espresso)

**Description:** Tests d'interface utilisateur natifs Android.

**Commandes:**

```bash
cd android
./gradlew connectedAndroidTest
```

---

## 🚀 Déploiement avec Fastlane

### Initialisation

Le Fastfile est déjà configuré à `fastlane/Fastfile`.

### Lanes Disponibles

#### 1. `fastlane android test`
Exécute les tests unitaires et UI.

```bash
fastlane android test
```

#### 2. `fastlane android build_debug`
Crée un APK de débogage.

```bash
fastlane android build_debug
```

#### 3. `fastlane android build_release`
Crée un bundle AAB pour la production.

```bash
fastlane android build_release
```

#### 4. `fastlane android deploy_internal`
**Déploie sur Google Play Store (piste interne)**

```bash
fastlane android deploy_internal
```

Prérequis:
1. Fichier JSON de compte de service Google Play
2. Placement dans le bon répertoire
3. Permissions configurées dans la console Google Play

#### 5. `fastlane android test_e2e`
Exécute les tests E2E Detox.

```bash
fastlane android test_e2e
```

### Configuration Google Play

1. **Créer un compte de service:**
   - Aller sur [Google Cloud Console](https://console.cloud.google.com)
   - Créer un projet ou en sélectionner un
   - Créer une clé de service JSON

2. **Placer la clé dans le bon répertoire:**
   ```bash
   mkdir -p ~/.config/fastlane/
   cp service-account.json ~/.config/fastlane/
   ```

3. **Mettre à jour `fastlane/Appfile`:**
   ```ruby
   default_locale: en-US
   identifier: com.monapp
   json_key_file: "~/.config/fastlane/service-account.json"
   ```

---

## 🔄 CI/CD avec GitHub Actions

### Workflow (`.github/workflows/mobile.yml`)

Le workflow automatise:
1. **Tests unitaires** à chaque push
2. **Build Release** sur la branche `main`
3. **Déploiement** sur Google Play (piste interne)

### Trigger

```yaml
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
```

### Jobs

| Job | Déclencheur | Actions |
|---|---|---|
| `test-android` | Chaque push | Tests unitaires, tests UI Gradle |
| `build-android-release` | Push sur `main` | Build du bundle AAB |
| `deploy-android-internal` | Succès de `build-android-release` | Déploiement sur Google Play |
| `lint-and-format` | Chaque push | Linter le code |

### Configuration des Secrets

1. Aller dans **Settings → Secrets and variables → Actions**
2. Créer un secret nommé `GOOGLE_PLAY_SERVICE_ACCOUNT`
3. Coller le contenu du fichier JSON de service Google Play

```bash
# Linux/macOS - Copier le contenu du JSON dans le secret
cat service-account.json | base64 | pbcopy
```

### Visualiser les Workflows

1. Aller dans l'onglet **Actions** du dépôt GitHub
2. Sélectionner **Test & Deploy Mobile**
3. Voir l'état des jobs et les logs

---

## 📝 Script Local de Déploiement

### Utilisation

```bash
chmod +x deploy.sh
./deploy.sh
```

### Étapes

1. **Nettoyage** - `npm run clean`
2. **Tests unitaires** - `npm test`
3. **Linting** - `npm run lint`
4. **Build Release** - `./gradlew bundleRelease`
5. **Déploiement Fastlane** - `fastlane android deploy_internal` (optionnel)

### Configuration Locale

Le script recherche:
- Clé de service Google Play dans `~/.gradle/gradle.properties`
- Ou la variable d'environnement `GOOGLE_PLAY_SERVICE_ACCOUNT`

---

## ✅ Checklist de Suivi

| # | Étape | Commande | Vérification |
|---|---|---|---|
| 1 | Environnement prêt | `npm -v` / `fastlane --version` | ✓ Versions correctes |
| 2 | Dépendances installées | `npm install` | ✓ node_modules créé |
| 3 | Tests unitaires | `npm test` | ✓ 0 failures |
| 4 | Build debug | `npm run android` | ✓ APK généré |
| 5 | Tests UI Gradle | `cd android && ./gradlew testDebugUnitTest` | ✓ Succès |
| 6 | Build release | `npm run build:release` | ✓ AAB généré |
| 7 | Signing configuré | Vérifier `android/app/build.gradle` | ✓ Clés présentes |
| 8 | Fastlane test | `fastlane android test` | ✓ Succès |
| 9 | Déploiement | `fastlane android deploy_internal` | ✓ Build visible dans Play Store |
| 10 | GitHub Actions | Push vers `main` | ✓ Pipeline vert |

---

## 🧩 Résumé des Commandes

```bash
# Tests
npm test                    # Tests unitaires
npm run test:coverage       # Avec rapport de couverture
npm run detox:build        # Build pour E2E
npm run detox:test         # Exécuter E2E

# Build
npm run build:release      # Build AAB release
npm run android            # Run debug sur device/émulateur
npm run clean              # Nettoyer

# Fastlane
fastlane android test      # Tests via Fastlane
fastlane android build_debug       # APK debug
fastlane android build_release     # AAB release
fastlane android deploy_internal   # Déployer sur Play Store

# Déploiement local
./deploy.sh                # Pipeline complet local
```

---

## 📌 Points Clés à Retenir

✅ **Tests d'abord** — Le pipeline bloque le déploiement si les tests échouent
✅ **Secrets sécurisés** — Ne jamais stocker les clés en clair
✅ **Workflow local avant push** — Exécuter `./deploy.sh` avant de pousser sur GitHub
✅ **Déploiement progressif** — Valider sur la piste `internal` avant de promouvoir
✅ **Dépendances à jour** — Exécuter régulièrement `npm audit fix`

---

## 🆘 Dépannage

### L'émulateur Detox n'est pas trouvé
```bash
# Créer l'émulateur avec le bon AVD
android create avd -n Pixel_3a_API_30_x86 -t "android-30" -b x86
```

### Google Play Deploy échoue
```bash
# Vérifier que le fichier JSON est accessible
cat ~/.config/fastlane/service-account.json

# Vérifier les permissions dans la console Google Play
# Le compte de service a besoin d'accès à "Release Management" et "App Content"
```

### Tests Jest échouent
```bash
# Nettoyer le cache Jest
npx jest --clearCache

# Exécuter un test spécifique
npm test -- __tests__/App.test.tsx
```

---

## 📚 Ressources

- [React Native Documentation](https://reactnative.dev)
- [Jest Testing](https://jestjs.io)
- [Detox E2E Testing](https://wix.github.io/Detox)
- [Fastlane Documentation](https://docs.fastlane.tools)
- [GitHub Actions](https://docs.github.com/en/actions)

