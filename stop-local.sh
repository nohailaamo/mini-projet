#!/bin/bash

# Script pour arrêter tous les services locaux
# Stop local services script

echo "========================================="
echo "Arrêt des services locaux"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Stop Spring Boot services
if [ -f logs/produit.pid ]; then
    PID=$(cat logs/produit.pid)
    echo -e "Arrêt du service Produit (PID: $PID)..."
    kill $PID 2>/dev/null || echo -e "${YELLOW}⚠️  Processus Produit déjà arrêté${NC}"
    rm -f logs/produit.pid
else
    echo -e "${YELLOW}⚠️  Service Produit non trouvé${NC}"
fi

if [ -f logs/commande.pid ]; then
    PID=$(cat logs/commande.pid)
    echo -e "Arrêt du service Commande (PID: $PID)..."
    kill $PID 2>/dev/null || echo -e "${YELLOW}⚠️  Processus Commande déjà arrêté${NC}"
    rm -f logs/commande.pid
else
    echo -e "${YELLOW}⚠️  Service Commande non trouvé${NC}"
fi

if [ -f logs/gateway.pid ]; then
    PID=$(cat logs/gateway.pid)
    echo -e "Arrêt de l'API Gateway (PID: $PID)..."
    kill $PID 2>/dev/null || echo -e "${YELLOW}⚠️  Processus Gateway déjà arrêté${NC}"
    rm -f logs/gateway.pid
else
    echo -e "${YELLOW}⚠️  API Gateway non trouvé${NC}"
fi

# Kill any remaining Spring Boot processes
echo ""
echo "Recherche d'autres processus Spring Boot..."
pkill -f "spring-boot:run" 2>/dev/null && echo -e "${GREEN}✓${NC} Processus Spring Boot supplémentaires arrêtés" || echo "Aucun processus Spring Boot supplémentaire trouvé"

echo ""
echo "========================================="
echo "Arrêt des conteneurs Docker (optionnel)"
echo "========================================="
echo ""

# Ask user if they want to stop Docker containers
read -p "Voulez-vous arrêter les conteneurs Docker (PostgreSQL, Keycloak)? (o/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[OoYy]$ ]]; then
    echo "Arrêt des conteneurs Docker..."
    
    if docker ps | grep -q "produit-db-local"; then
        docker stop produit-db-local && echo -e "${GREEN}✓${NC} PostgreSQL Produit arrêté"
    fi
    
    if docker ps | grep -q "commande-db-local"; then
        docker stop commande-db-local && echo -e "${GREEN}✓${NC} PostgreSQL Commande arrêté"
    fi
    
    if docker ps | grep -q "keycloak-local"; then
        docker stop keycloak-local && echo -e "${GREEN}✓${NC} Keycloak arrêté"
    fi
    
    echo ""
    read -p "Voulez-vous supprimer les conteneurs? (o/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[OoYy]$ ]]; then
        echo "Suppression des conteneurs..."
        docker rm produit-db-local 2>/dev/null && echo -e "${GREEN}✓${NC} Conteneur produit-db-local supprimé"
        docker rm commande-db-local 2>/dev/null && echo -e "${GREEN}✓${NC} Conteneur commande-db-local supprimé"
        docker rm keycloak-local 2>/dev/null && echo -e "${GREEN}✓${NC} Conteneur keycloak-local supprimé"
    fi
else
    echo "Les conteneurs Docker ne sont pas arrêtés."
fi

echo ""
echo -e "${GREEN}✅ Arrêt terminé${NC}"
echo ""
echo "💡 Les logs sont toujours disponibles dans le dossier logs/"
echo "💡 Pour redémarrer: ./start-local.sh"
echo ""
