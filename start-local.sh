#!/bin/bash

# Script pour démarrer l'application en local SANS Docker (sauf pour les BDD)
# Start local script for Mini-Projet Microservices WITHOUT Docker containerization

set -e

echo "=============================================="
echo "Mini-Projet - Démarrage Local (Sans Docker)"
echo "Local Start Script (Without Docker)"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
USE_H2=false
USE_DOCKER_DB=true
START_KEYCLOAK=false
BUILD_SERVICES=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --h2)
      USE_H2=true
      USE_DOCKER_DB=false
      shift
      ;;
    --no-docker)
      USE_DOCKER_DB=false
      shift
      ;;
    --with-keycloak)
      START_KEYCLOAK=true
      shift
      ;;
    --no-build)
      BUILD_SERVICES=false
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  --h2              Utiliser H2 en mémoire (pas besoin de PostgreSQL)"
      echo "  --no-docker       Ne pas démarrer Docker du tout (nécessite PostgreSQL local)"
      echo "  --with-keycloak   Démarrer Keycloak avec Docker"
      echo "  --no-build        Ne pas recompiler les services"
      echo "  --help            Afficher cette aide"
      echo ""
      echo "Exemples:"
      echo "  $0                      # Mode par défaut: PostgreSQL Docker"
      echo "  $0 --h2                 # Mode H2 (le plus simple)"
      echo "  $0 --with-keycloak      # Avec Keycloak"
      exit 0
      ;;
    *)
      echo -e "${RED}Option inconnue: $1${NC}"
      echo "Utilisez --help pour voir les options disponibles"
      exit 1
      ;;
  esac
done

# Check prerequisites
echo "========================================="
echo "Vérification des prérequis"
echo "========================================="

# Check Java
if ! command -v java &> /dev/null; then
    echo -e "${RED}❌ Java n'est pas installé. Installez Java 17 ou supérieur.${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Java est installé: $(java -version 2>&1 | head -n 1)"

# Check Maven
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}❌ Maven n'est pas installé. Installez Maven 3.8+.${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Maven est installé: $(mvn -version | head -n 1)"

# Check Docker if needed
if [ "$USE_DOCKER_DB" = true ] || [ "$START_KEYCLOAK" = true ]; then
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker n'est pas installé mais nécessaire pour les bases de données.${NC}"
        echo "Installez Docker ou utilisez --h2 ou --no-docker avec PostgreSQL local"
        exit 1
    fi
    echo -e "${GREEN}✓${NC} Docker est installé"
fi

echo ""

# Function to wait for service
wait_for_service() {
    local name=$1
    local url=$2
    local max_attempts=30
    local attempt=1
    
    echo -e "${YELLOW}⏳ Attente de $name...${NC}"
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} $name est prêt!"
            return 0
        fi
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}✗${NC} Timeout en attendant $name"
    return 1
}

# Start databases
if [ "$USE_H2" = true ]; then
    echo "========================================="
    echo "Mode H2 - Bases de données en mémoire"
    echo "========================================="
    echo -e "${GREEN}✓${NC} Aucune base de données externe nécessaire"
    echo ""
    DB_PROFILE="h2"
elif [ "$USE_DOCKER_DB" = true ]; then
    echo "========================================="
    echo "Démarrage des bases de données PostgreSQL"
    echo "========================================="
    
    # Check if containers already exist
    if docker ps -a | grep -q "produit-db-local"; then
        echo "Conteneur produit-db-local existe déjà, redémarrage..."
        docker start produit-db-local || docker run -d \
          --name produit-db-local \
          -e POSTGRES_DB=produitdb \
          -e POSTGRES_USER=postgres \
          -e POSTGRES_PASSWORD=admin \
          -p 5433:5432 \
          postgres:15-alpine
    else
        echo "Démarrage de PostgreSQL pour Produit (port 5433)..."
        docker run -d \
          --name produit-db-local \
          -e POSTGRES_DB=produitdb \
          -e POSTGRES_USER=postgres \
          -e POSTGRES_PASSWORD=admin \
          -p 5433:5432 \
          postgres:15-alpine
    fi
    
    if docker ps -a | grep -q "commande-db-local"; then
        echo "Conteneur commande-db-local existe déjà, redémarrage..."
        docker start commande-db-local || docker run -d \
          --name commande-db-local \
          -e POSTGRES_DB=commandedb \
          -e POSTGRES_USER=postgres \
          -e POSTGRES_PASSWORD=admin \
          -p 5434:5432 \
          postgres:15-alpine
    else
        echo "Démarrage de PostgreSQL pour Commande (port 5434)..."
        docker run -d \
          --name commande-db-local \
          -e POSTGRES_DB=commandedb \
          -e POSTGRES_USER=postgres \
          -e POSTGRES_PASSWORD=admin \
          -p 5434:5432 \
          postgres:15-alpine
    fi
    
    echo -e "${YELLOW}⏳ Attente du démarrage des bases de données (10 secondes)...${NC}"
    sleep 10
    echo -e "${GREEN}✓${NC} Bases de données PostgreSQL démarrées"
    echo ""
    DB_PROFILE="default"
else
    echo "========================================="
    echo "Mode PostgreSQL Local"
    echo "========================================="
    echo -e "${YELLOW}⚠️  Assurez-vous que PostgreSQL est installé et démarré localement${NC}"
    echo "Port par défaut: 5432"
    echo "Bases de données requises: produitdb, commandedb"
    echo ""
    DB_PROFILE="default"
fi

# Start Keycloak if requested
if [ "$START_KEYCLOAK" = true ]; then
    echo "========================================="
    echo "Démarrage de Keycloak"
    echo "========================================="
    
    if docker ps -a | grep -q "keycloak-local"; then
        echo "Conteneur keycloak-local existe déjà, redémarrage..."
        docker start keycloak-local
    else
        echo "Démarrage de Keycloak (port 8180)..."
        docker run -d \
          --name keycloak-local \
          -p 8180:8080 \
          -e KEYCLOAK_ADMIN=admin \
          -e KEYCLOAK_ADMIN_PASSWORD=admin \
          quay.io/keycloak/keycloak:23.0 \
          start-dev
    fi
    
    echo -e "${YELLOW}⏳ Attente de Keycloak (cela peut prendre 30-60 secondes)...${NC}"
    sleep 20
    if wait_for_service "Keycloak" "http://localhost:8180"; then
        echo ""
        echo -e "${YELLOW}⚠️  N'oubliez pas de configurer Keycloak:${NC}"
        echo "   URL: http://localhost:8180"
        echo "   Admin: admin / admin"
        echo "   Consultez README.md pour la configuration complète"
        echo ""
    fi
else
    echo -e "${YELLOW}ℹ️  Keycloak non démarré. Utilisez --with-keycloak si nécessaire.${NC}"
    echo -e "${YELLOW}ℹ️  Note: La sécurité OAuth2 devra être désactivée ou configurée.${NC}"
    echo ""
fi

# Build services
if [ "$BUILD_SERVICES" = true ]; then
    echo "========================================="
    echo "Compilation des services"
    echo "========================================="
    
    echo "Compilation du service Produit..."
    cd Produit
    mvn clean install -DskipTests > ../logs/produit-build.log 2>&1 &
    PRODUIT_BUILD_PID=$!
    
    echo "Compilation du service Commande..."
    cd ../Commande
    mvn clean install -DskipTests > ../logs/commande-build.log 2>&1 &
    COMMANDE_BUILD_PID=$!
    
    echo "Compilation de l'API Gateway..."
    cd ../Api-gateway
    mvn clean install -DskipTests > ../logs/gateway-build.log 2>&1 &
    GATEWAY_BUILD_PID=$!
    
    cd ..
    
    echo -e "${YELLOW}⏳ Attente de la fin des compilations...${NC}"
    
    # Wait for builds to complete
    if wait $PRODUIT_BUILD_PID; then
        echo -e "${GREEN}✓${NC} Service Produit compilé"
    else
        echo -e "${RED}✗${NC} Erreur lors de la compilation de Produit"
        cat logs/produit-build.log | tail -20
        exit 1
    fi
    
    if wait $COMMANDE_BUILD_PID; then
        echo -e "${GREEN}✓${NC} Service Commande compilé"
    else
        echo -e "${RED}✗${NC} Erreur lors de la compilation de Commande"
        cat logs/commande-build.log | tail -20
        exit 1
    fi
    
    if wait $GATEWAY_BUILD_PID; then
        echo -e "${GREEN}✓${NC} API Gateway compilé"
    else
        echo -e "${RED}✗${NC} Erreur lors de la compilation de Gateway"
        cat logs/gateway-build.log | tail -20
        exit 1
    fi
    
    echo ""
fi

# Start services
echo "========================================="
echo "Démarrage des services Spring Boot"
echo "========================================="

# Create logs directory
mkdir -p logs

# Start Produit service
echo "Démarrage du service Produit (port 8081)..."
cd Produit
if [ "$USE_H2" = true ]; then
    nohup mvn spring-boot:run -Dspring-boot.run.profiles=h2 > ../logs/produit.log 2>&1 &
else
    nohup mvn spring-boot:run > ../logs/produit.log 2>&1 &
fi
PRODUIT_PID=$!
echo $PRODUIT_PID > ../logs/produit.pid
cd ..

sleep 5

# Start Commande service
echo "Démarrage du service Commande (port 8082)..."
cd Commande
if [ "$USE_H2" = true ]; then
    nohup mvn spring-boot:run -Dspring-boot.run.profiles=h2 > ../logs/commande.log 2>&1 &
else
    nohup mvn spring-boot:run > ../logs/commande.log 2>&1 &
fi
COMMANDE_PID=$!
echo $COMMANDE_PID > ../logs/commande.pid
cd ..

sleep 5

# Start API Gateway
echo "Démarrage de l'API Gateway (port 8888)..."
cd Api-gateway
nohup mvn spring-boot:run > ../logs/gateway.log 2>&1 &
GATEWAY_PID=$!
echo $GATEWAY_PID > ../logs/gateway.pid
cd ..

echo ""
echo -e "${YELLOW}⏳ Attente du démarrage des services (cela peut prendre 30-60 secondes)...${NC}"
echo ""

# Wait for services to be ready
sleep 20

if wait_for_service "Service Produit" "http://localhost:8081/actuator/health"; then
    echo ""
fi

if wait_for_service "Service Commande" "http://localhost:8082/actuator/health"; then
    echo ""
fi

if wait_for_service "API Gateway" "http://localhost:8888/actuator/health"; then
    echo ""
fi

# Display success message
echo ""
echo "========================================="
echo -e "${GREEN}✅ Tous les services sont démarrés!${NC}"
echo "========================================="
echo ""
echo -e "${BLUE}🌐 Services disponibles:${NC}"
echo "   - Service Produit:  http://localhost:8081"
echo "   - Service Commande: http://localhost:8082"
echo "   - API Gateway:      http://localhost:8888"
if [ "$START_KEYCLOAK" = true ]; then
    echo "   - Keycloak:         http://localhost:8180"
fi
echo ""

echo -e "${BLUE}📊 Actuator Health Checks:${NC}"
echo "   - http://localhost:8081/actuator/health"
echo "   - http://localhost:8082/actuator/health"
echo "   - http://localhost:8888/actuator/health"
echo ""

echo -e "${BLUE}📚 API Documentation (Swagger):${NC}"
echo "   - http://localhost:8081/swagger-ui.html"
echo "   - http://localhost:8082/swagger-ui.html"
echo "   - http://localhost:8888/swagger-ui.html"
echo ""

if [ "$USE_H2" = true ]; then
    echo -e "${BLUE}🗄️  Consoles H2 (pour debug):${NC}"
    echo "   - http://localhost:8081/h2-console (JDBC URL: jdbc:h2:mem:produitdb)"
    echo "   - http://localhost:8082/h2-console (JDBC URL: jdbc:h2:mem:commandedb)"
    echo ""
fi

echo -e "${BLUE}📝 Logs:${NC}"
echo "   - logs/produit.log"
echo "   - logs/commande.log"
echo "   - logs/gateway.log"
echo ""
echo "   Pour suivre les logs en temps réel:"
echo "   tail -f logs/produit.log"
echo ""

echo -e "${BLUE}🔧 Gestion des services:${NC}"
echo "   - Pour arrêter: ./stop-local.sh"
echo "   - Pour voir les logs: tail -f logs/*.log"
echo ""

echo -e "${BLUE}🚀 Étapes suivantes:${NC}"
echo "   1. Démarrez le frontend:"
echo "      cd frontend"
echo "      npm install"
echo "      npm start"
echo ""
echo "   2. Accédez à l'application:"
echo "      http://localhost:3000"
echo ""

if [ "$START_KEYCLOAK" = false ]; then
    echo -e "${YELLOW}⚠️  Note: Keycloak n'est pas démarré${NC}"
    echo "   Pour l'authentification OAuth2, soit:"
    echo "   - Relancez avec --with-keycloak"
    echo "   - Désactivez la sécurité (voir LOCAL_SETUP.md)"
    echo ""
fi

echo -e "${GREEN}✨ Bon développement!${NC}"
echo ""
