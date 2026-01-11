#!/bin/bash

# Quick Start Script for Mini-Projet Microservices
# This script helps you get started quickly with the application

set -e

echo "========================================="
echo "Mini-Projet Microservices - Quick Start"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas installé. Veuillez installer Docker Desktop.${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose n'est pas installé. Veuillez installer Docker Compose.${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Docker est installé"
echo -e "${GREEN}✓${NC} Docker Compose est installé"
echo ""

# Step 1: Build and start services
echo "========================================="
echo "Étape 1: Construction et démarrage des services"
echo "========================================="
echo -e "${YELLOW}⏳ Cela peut prendre 5-10 minutes la première fois...${NC}"
echo ""

docker-compose up -d --build

echo ""
echo -e "${GREEN}✓${NC} Tous les services sont démarrés!"
echo ""

# Step 2: Wait for Keycloak
echo "========================================="
echo "Étape 2: Attente du démarrage de Keycloak"
echo "========================================="
echo -e "${YELLOW}⏳ Keycloak prend environ 30-60 secondes...${NC}"
echo ""

for i in {1..60}; do
    if curl -s http://localhost:8180/health/ready > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Keycloak est prêt!"
        break
    fi
    echo -n "."
    sleep 2
done

echo ""
echo ""

# Step 3: Instructions for Keycloak configuration
echo "========================================="
echo "Étape 3: Configuration de Keycloak"
echo "========================================="
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Vous devez configurer Keycloak manuellement${NC}"
echo ""
echo "1. Ouvrez votre navigateur et allez à:"
echo -e "   ${GREEN}http://localhost:8180${NC}"
echo ""
echo "2. Connectez-vous avec:"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "3. Suivez le guide de configuration:"
echo -e "   ${GREEN}docs/keycloak-setup.md${NC}"
echo ""
echo "   Résumé rapide:"
echo "   - Créer realm: microservices-app"
echo "   - Créer client: frontend-client"
echo "   - Créer rôles: ADMIN, CLIENT"
echo "   - Créer utilisateurs: admin/admin (ADMIN), client/client (CLIENT)"
echo ""
echo -e "${YELLOW}Appuyez sur Entrée après avoir configuré Keycloak...${NC}"
read

# Step 4: Check services
echo ""
echo "========================================="
echo "Étape 4: Vérification des services"
echo "========================================="
echo ""

check_service() {
    local name=$1
    local url=$2
    
    if curl -s $url > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name est opérationnel"
    else
        echo -e "${RED}✗${NC} $name n'est pas accessible"
    fi
}

check_service "Frontend" "http://localhost:3000"
check_service "API Gateway" "http://localhost:8888/actuator/health"
check_service "Service Produit" "http://localhost:8081/actuator/health"
check_service "Service Commande" "http://localhost:8082/actuator/health"
check_service "Keycloak" "http://localhost:8180/health/ready"

echo ""
echo "========================================="
echo "✅ Installation Terminée!"
echo "========================================="
echo ""
echo "🌐 Accédez à l'application:"
echo -e "   Frontend: ${GREEN}http://localhost:3000${NC}"
echo ""
echo "👤 Utilisateurs de test:"
echo "   Admin:  admin/admin   (ADMIN)"
echo "   Client: client/client (CLIENT)"
echo ""
echo "📚 Documentation:"
echo "   README.md - Guide complet"
echo "   docs/keycloak-setup.md - Configuration Keycloak"
echo "   docs/architecture.md - Architecture du système"
echo ""
echo "🛠️  Commandes utiles:"
echo "   docker-compose ps          - Voir l'état des services"
echo "   docker-compose logs -f     - Voir les logs en temps réel"
echo "   docker-compose down        - Arrêter tous les services"
echo "   docker-compose down -v     - Arrêter et supprimer les volumes"
echo ""
echo "🔒 DevSecOps:"
echo "   ./.devsecops/security-scan.sh - Lancer les analyses de sécurité"
echo ""
echo -e "${GREEN}Bon développement! 🚀${NC}"
echo ""
