#!/bin/bash
# Script de test pour vérifier que le frontend récupère bien les produits et commandes

echo "🔍 Test de récupération des données du Frontend"
echo "================================================\n"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour attendre qu'un service soit disponible
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=30
    local attempt=0

    echo "Attente de $service_name sur $url..."
    while [ $attempt -lt $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ $service_name est disponible${NC}"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 1
    done

    echo -e "${RED}✗ $service_name n'a pas pu démarrer${NC}"
    return 1
}

echo "1️⃣  Vérification de Keycloak..."
if curl -s http://localhost:8180 > /dev/null; then
    echo -e "${GREEN}✓ Keycloak est actif${NC}\n"
else
    echo -e "${RED}✗ Keycloak n'est pas actif${NC}\n"
fi

echo "2️⃣  Vérification du Service Produit..."
if curl -s -H "Authorization: Bearer test" http://localhost:8081/api/produits > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Service Produit répond${NC}\n"
else
    echo -e "${YELLOW}⚠ Service Produit peut nécessiter authentication${NC}\n"
fi

echo "3️⃣  Vérification du Service Commande..."
if curl -s -H "Authorization: Bearer test" http://localhost:8082/api/commandes > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Service Commande répond${NC}\n"
else
    echo -e "${YELLOW}⚠ Service Commande peut nécessiter authentication${NC}\n"
fi

echo "4️⃣  Vérification de l'API Gateway..."
if curl -s -H "Authorization: Bearer test" http://localhost:8888/api/produits > /dev/null 2>&1; then
    echo -e "${GREEN}✓ API Gateway répond${NC}\n"
else
    echo -e "${YELLOW}⚠ API Gateway peut nécessiter authentication${NC}\n"
fi

echo "5️⃣  Vérification du Frontend..."
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Frontend est actif${NC}\n"
else
    echo -e "${RED}✗ Frontend n'est pas actif${NC}\n"
fi

echo ""
echo "================================================"
echo "📋 Étapes pour tester le Frontend:"
echo "================================================"
echo ""
echo "1. Ouvrir http://localhost:3000 dans le navigateur"
echo "2. Cliquer sur 'Se connecter'"
echo "3. Se connecter avec:"
echo "   - Admin: admin / admin"
echo "   - Client: client / client"
echo ""
echo "4. Vérifier que les produits s'affichent:"
echo "   - Page 'Produits' devrait afficher 8 produits"
echo ""
echo "5. Pour CLIENT - Vérifier les commandes:"
echo "   - Aller à l'onglet 'Commandes'"
echo "   - Créer une nouvelle commande"
echo "   - Vérifier qu'elle apparaît dans la liste"
echo ""
echo "6. Pour ADMIN - Vérifier toutes les commandes:"
echo "   - Aller à l'onglet 'Toutes les Commandes'"
echo "   - Devrait afficher toutes les commandes du système"
echo ""
echo "================================================"
echo "🔧 Debugging (F12 - Console du navigateur):"
echo "================================================"
echo ""
echo "Les logs suivants doivent apparaître:"
echo "  ✓ 'Chargement des produits...'"
echo "  ✓ 'Produits reçus: [...]'"
echo "  ✓ 'Chargement des commandes...'"
echo "  ✓ 'Commandes reçues: [...]'"
echo ""
echo "En cas d'erreur, chercher:"
echo "  ✗ 'Erreur complète: {...}'"
echo "  ✗ 'CORS error'"
echo "  ✗ 'Unauthorized'"
echo ""

