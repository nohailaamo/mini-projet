#!/bin/bash

# Script d'analyse de sécurité DevSecOps
# Ce script exécute plusieurs outils de sécurité sur le projet

set -e

echo "======================================"
echo "Analyse de Sécurité DevSecOps"
echo "======================================"
echo ""

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. Analyse statique avec SonarQube (nécessite un serveur SonarQube)
echo "1. Analyse statique du code avec SonarQube"
echo "-------------------------------------------"
if command -v sonar-scanner &> /dev/null; then
    log_info "Lancement de SonarQube Scanner..."
    sonar-scanner || log_warn "SonarQube Scanner a échoué ou n'a pas pu se connecter au serveur"
else
    log_warn "sonar-scanner n'est pas installé. Téléchargez-le depuis https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/"
fi
echo ""

# 2. Analyse des dépendances avec OWASP Dependency-Check
echo "2. Analyse des dépendances avec OWASP Dependency-Check"
echo "-------------------------------------------------------"
if command -v dependency-check &> /dev/null; then
    log_info "Analyse des dépendances Java..."
    
    # Analyse du micro-service Produit
    log_info "Analyse de Produit..."
    dependency-check --project "Produit" --scan Produit/pom.xml --format HTML --out .devsecops/dependency-check-produit
    
    # Analyse du micro-service Commande
    log_info "Analyse de Commande..."
    dependency-check --project "Commande" --scan Commande/pom.xml --format HTML --out .devsecops/dependency-check-commande
    
    # Analyse de l'API Gateway
    log_info "Analyse de Api-gateway..."
    dependency-check --project "Api-gateway" --scan Api-gateway/pom.xml --format HTML --out .devsecops/dependency-check-gateway
    
    log_info "Rapports OWASP générés dans .devsecops/"
else
    log_warn "OWASP Dependency-Check n'est pas installé."
    log_info "Installation avec Maven:"
    log_info "  cd Produit && mvn org.owasp:dependency-check-maven:check"
    log_info "  cd Commande && mvn org.owasp:dependency-check-maven:check"
    log_info "  cd Api-gateway && mvn org.owasp:dependency-check-maven:check"
fi
echo ""

# 3. Analyse des images Docker avec Trivy
echo "3. Scan des images Docker avec Trivy"
echo "-------------------------------------"
if command -v trivy &> /dev/null; then
    log_info "Scanning des images Docker..."
    
    # Build des images si nécessaire
    log_info "Build des images Docker..."
    docker-compose build || log_warn "Échec du build Docker"
    
    # Scan de chaque image
    log_info "Scan de l'image Produit..."
    trivy image --severity HIGH,CRITICAL mini-projet-produit-service:latest > .devsecops/trivy-produit.txt || true
    
    log_info "Scan de l'image Commande..."
    trivy image --severity HIGH,CRITICAL mini-projet-commande-service:latest > .devsecops/trivy-commande.txt || true
    
    log_info "Scan de l'image Gateway..."
    trivy image --severity HIGH,CRITICAL mini-projet-api-gateway:latest > .devsecops/trivy-gateway.txt || true
    
    log_info "Scan de l'image Frontend..."
    trivy image --severity HIGH,CRITICAL mini-projet-frontend:latest > .devsecops/trivy-frontend.txt || true
    
    log_info "Rapports Trivy générés dans .devsecops/"
else
    log_warn "Trivy n'est pas installé. Installation:"
    log_info "  brew install aquasecurity/trivy/trivy  (macOS)"
    log_info "  apt-get install trivy                   (Debian/Ubuntu)"
    log_info "  https://github.com/aquasecurity/trivy   (Autres)"
fi
echo ""

# 4. Vérification des secrets avec git-secrets (optionnel)
echo "4. Vérification des secrets dans le code"
echo "-----------------------------------------"
if command -v git-secrets &> /dev/null; then
    log_info "Scan des secrets..."
    git secrets --scan || log_warn "Des secrets potentiels ont été détectés!"
else
    log_warn "git-secrets n'est pas installé. Installation:"
    log_info "  https://github.com/awslabs/git-secrets"
fi
echo ""

# Résumé
echo "======================================"
echo "Résumé de l'analyse de sécurité"
echo "======================================"
log_info "Les rapports sont disponibles dans le dossier .devsecops/"
log_info "Veuillez consulter les rapports pour les vulnérabilités détectées"
echo ""
log_warn "IMPORTANT: Corrigez toutes les vulnérabilités CRITICAL et HIGH avant le déploiement"
echo ""
