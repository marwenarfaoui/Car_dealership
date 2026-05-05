#!/bin/bash
set -e

# Script local tout-en-un pour tests et déploiement
# Usage: chmod +x deploy.sh && ./deploy.sh

echo "=========================================="
echo "🚀 Démarrage du pipeline de déploiement"
echo "=========================================="

# Déterminer le répertoire du projet
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_step() {
  echo -e "${GREEN}=== $1 ===${NC}"
}

log_error() {
  echo -e "${RED}❌ Erreur: $1${NC}"
  exit 1
}

log_warning() {
  echo -e "${YELLOW}⚠️  Attention: $1${NC}"
}

# Étape 1: Nettoyage
log_step "1. Nettoyage du répertoire"
npm run clean || log_warning "Nettoyage partiel effectué"

# Étape 2: Tests unitaires
log_step "2. Lancement des tests unitaires"
npm test || log_error "Les tests unitaires ont échoué"

# Étape 3: Linting
log_step "3. Vérification du code avec ESLint"
npm run lint || log_warning "Certains problèmes de lint détectés"

# Étape 4: Build Android Release
log_step "4. Build de l'APK/AAB Android release"
cd android
./gradlew clean bundleRelease || log_error "Build Android a échoué"
cd ..

# Étape 5: Tests E2E (optionnel - décommenter si l'émulateur est disponible)
# log_step "5. Tests E2E avec Detox"
# npm run detox:build || log_warning "Build Detox a échoué"
# npm run detox:test || log_warning "Tests E2E Detox ont échoué"

# Étape 6: Déploiement avec Fastlane
log_step "5. Déploiement sur Google Play Store (piste interne)"

# Vérifier si la clé de service Google Play est disponible
if [ -f "$HOME/.gradle/gradle.properties" ]; then
  log_step "Clé Google Play trouvée"
  cd fastlane
  fastlane android deploy_internal || log_error "Déploiement Fastlane a échoué"
  cd ..
else
  log_warning "Clé de service Google Play non trouvée."
  log_warning "Pour activer le déploiement automatique, configurez:"
  log_warning "  - GOOGLE_PLAY_SERVICE_ACCOUNT (fichier JSON)"
  log_warning "  - Placement du fichier dans ~/.gradle/gradle.properties"
fi

# Étape 7: Résumé
echo ""
echo "=========================================="
echo -e "${GREEN}✅ Déploiement terminé avec succès!${NC}"
echo "=========================================="
echo ""
echo "Les artefacts ont été générés:"
echo "  - Android Bundle (AAB): android/app/build/outputs/bundle/release/app-release.aab"
echo ""
echo "Prochaines étapes:"
echo "  1. Vérifier la build dans la console Google Play Store"
echo "  2. Promouvoir de la piste 'internal' vers 'alpha', 'beta', ou 'production'"
echo "  3. Configurer les notes de version dans la console Play Store"
echo ""
