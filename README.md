# Mini-Projet: Application Microservices Sécurisée

Application web moderne basée sur une architecture microservices sécurisée avec Spring Boot, React et Keycloak.

## 📋 Table des matières

- [Architecture](#architecture)
- [Technologies](#technologies)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Démarrage](#démarrage)
- [Utilisation](#utilisation)
- [Sécurité](#sécurité)
- [DevSecOps](#devsecops)
- [Documentation API](#documentation-api)
- [Tests](#tests)
- [Déploiement](#déploiement)

## 🏗 Architecture

L'application est composée des services suivants:

```
┌─────────────┐
│   Frontend  │ (React + Keycloak)
│  (Port 3000)│
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ API Gateway │ (Spring Cloud Gateway)
│ (Port 8888) │
└──────┬──────┘
       │
       ├──────────────┐
       ▼              ▼
┌─────────────┐  ┌─────────────┐
│  Produit    │  │  Commande   │
│ (Port 8081) │  │ (Port 8082) │
└──────┬──────┘  └──────┬──────┘
       │                │
       ▼                ▼
┌─────────────┐  ┌─────────────┐
│ PostgreSQL  │  │ PostgreSQL  │
│  Produit    │  │  Commande   │
└─────────────┘  └─────────────┘

┌─────────────┐
│  Keycloak   │ (Serveur d'authentification)
│ (Port 8180) │
└─────────────┘
```

### Principes architecturaux

- **Architecture microservices**: Services indépendants et déployables séparément
- **API Gateway**: Point d'entrée unique pour toutes les requêtes
- **Base de données par service**: Isolation des données
- **Sécurité OAuth2/OIDC**: Authentification et autorisation via Keycloak
- **Communication REST**: API RESTful entre services
- **Propagation JWT**: Token JWT propagé dans les appels inter-services

## 🛠 Technologies

### Backend
- **Spring Boot 3.2.1**: Framework Java pour microservices
- **Spring Cloud Gateway**: API Gateway
- **Spring Security**: Sécurité et OAuth2
- **Spring Data JPA**: Accès aux données
- **OpenFeign**: Communication inter-services
- **PostgreSQL**: Base de données relationnelle (ou H2 pour dev local)

### Frontend
- **React 18**: Framework JavaScript
- **TypeScript**: Typage statique
- **React Router**: Navigation
- **Keycloak JS**: Authentification OAuth2/OIDC
- **Axios**: Client HTTP

### Sécurité & Authentification
- **Keycloak**: Serveur d'identité et d'accès
- **JWT**: Tokens d'authentification
- **OAuth2/OpenID Connect**: Protocoles d'authentification

### DevOps & Conteneurisation
- **Docker**: Conteneurisation
- **Docker Compose**: Orchestration multi-conteneurs
- **Maven**: Build Java

### DevSecOps
- **SonarQube**: Analyse statique du code
- **OWASP Dependency-Check**: Analyse des dépendances
- **Trivy**: Scan des images Docker

## 📦 Prérequis

### Pour Docker (déploiement conteneurisé)
- Docker Desktop (version 20+)
- Docker Compose (version 2+)

### Pour développement local (SANS Docker)
- **Java 17 ou supérieur** (JDK)
- **Maven 3.8+**
- **Node.js 18+** et **npm**
- **PostgreSQL 15** (optionnel, peut être remplacé par H2 en mémoire)

## 🚀 Installation

### 1. Cloner le repository

```bash
git clone https://github.com/nohailaamo/mini-projet.git
cd mini-projet
```

### 2. Configuration de Keycloak

Avant le premier démarrage, Keycloak doit être configuré:

1. Démarrez Keycloak seul:
```bash
docker-compose up -d keycloak keycloak-db
```

2. Attendez que Keycloak démarre (environ 30-60 secondes)

3. Accédez à l'admin console: http://localhost:8180
   - Username: `admin`
   - Password: `admin`

4. Créez un realm `microservices-app`:
   - Cliquez sur "Create Realm"
   - Name: `microservices-app`
   - Enabled: ON
   - Save

5. Créez un client `frontend-client`:
   - Clients → Create Client
   - Client ID: `frontend-client`
   - Client Protocol: `openid-connect`
   - Valid Redirect URIs: `http://localhost:3000/*`
   - Web Origins: `http://localhost:3000`
   - Save

6. Créez les rôles:
   - Realm Roles → Create Role
   - Créez deux rôles: `ADMIN` et `CLIENT`

7. Créez des utilisateurs de test:
   
   **Admin**:
   - Username: `admin`
   - Email: `admin@test.com`
   - First Name: `Admin`
   - Last Name: `User`
   - Email Verified: ON
   - Credentials → Set Password: `admin` (Temporary: OFF)
   - Role Mappings → Assign role: `ADMIN`
   
   **Client**:
   - Username: `client`
   - Email: `client@test.com`
   - First Name: `Client`
   - Last Name: `User`
   - Email Verified: ON
   - Credentials → Set Password: `client` (Temporary: OFF)
   - Role Mappings → Assign role: `CLIENT`

## 🎯 Démarrage

### ⚡ Démarrage Local SANS Docker (Recommandé pour développement)

**Option la plus simple - Avec H2 en mémoire :**

```bash
# Démarrage automatique de tous les services
./start-local.sh --h2

# Puis démarrer le frontend dans un nouveau terminal
cd frontend
npm install
npm start
```

**Ou avec PostgreSQL Docker uniquement (pour les bases de données) :**

```bash
# Démarrage automatique avec PostgreSQL dans Docker
./start-local.sh

# Puis démarrer le frontend
cd frontend
npm install
npm start
```

**📚 Pour plus d'options et de détails, consultez [LOCAL_SETUP.md](LOCAL_SETUP.md)**

Les services seront accessibles :
- Frontend: http://localhost:3000
- API Gateway: http://localhost:8888
- Service Produit: http://localhost:8081
- Service Commande: http://localhost:8082

**Arrêter les services :**
```bash
./stop-local.sh
```

---

### 🐳 Démarrage complet avec Docker Compose

```bash
# Construire et démarrer tous les services
docker-compose up --build

# Ou en arrière-plan
docker-compose up -d --build
```

Les services seront accessibles aux adresses suivantes:
- Frontend: http://localhost:3000
- API Gateway: http://localhost:8888
- Service Produit: http://localhost:8081
- Service Commande: http://localhost:8082
- Keycloak: http://localhost:8180

### Démarrage pour le développement

#### Backend (chaque microservice séparément)

```bash
# Service Produit
cd Produit
mvn spring-boot:run

# Service Commande
cd Commande
mvn spring-boot:run

# API Gateway
cd Api-gateway
mvn spring-boot:run
```

#### Frontend

```bash
cd frontend
npm install
npm start
```

## 📝 Configuration

### Variables d'environnement

#### Service Produit
- `SPRING_DATASOURCE_URL`: URL de la base de données
- `SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI`: URL Keycloak

#### Service Commande
- `SPRING_DATASOURCE_URL`: URL de la base de données
- `PRODUIT_SERVICE_URL`: URL du service Produit
- `SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI`: URL Keycloak

#### API Gateway
- `SPRING_CLOUD_GATEWAY_ROUTES_0_URI`: URL service Produit
- `SPRING_CLOUD_GATEWAY_ROUTES_1_URI`: URL service Commande
- `SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI`: URL Keycloak

## 🎮 Utilisation

### Se connecter

1. Accédez à http://localhost:3000
2. Cliquez sur "Se connecter"
3. Utilisez les identifiants:
   - Admin: `admin` / `admin`
   - Client: `client` / `client`

### Fonctionnalités ADMIN

- Voir tous les produits
- Ajouter un produit
- Modifier un produit
- Supprimer un produit
- Voir toutes les commandes

### Fonctionnalités CLIENT

- Voir tous les produits
- Créer une commande
- Voir ses propres commandes

### API REST

#### Produits (via API Gateway)

```bash
# Liste tous les produits
GET http://localhost:8888/api/produits
Authorization: Bearer <token>

# Récupère un produit
GET http://localhost:8888/api/produits/{id}
Authorization: Bearer <token>

# Crée un produit (ADMIN)
POST http://localhost:8888/api/produits
Authorization: Bearer <token>
Content-Type: application/json

{
  "nom": "Produit Test",
  "description": "Description du produit",
  "prix": 99.99,
  "quantiteStock": 50
}

# Modifie un produit (ADMIN)
PUT http://localhost:8888/api/produits/{id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "nom": "Produit Modifié",
  "description": "Nouvelle description",
  "prix": 89.99,
  "quantiteStock": 45
}

# Supprime un produit (ADMIN)
DELETE http://localhost:8888/api/produits/{id}
Authorization: Bearer <token>
```

#### Commandes (via API Gateway)

```bash
# Crée une commande (CLIENT)
POST http://localhost:8888/api/commandes
Authorization: Bearer <token>
Content-Type: application/json

{
  "lignes": [
    {
      "produitId": 1,
      "quantite": 2,
      "prix": 99.99
    }
  ]
}

# Liste mes commandes (CLIENT)
GET http://localhost:8888/api/commandes
Authorization: Bearer <token>

# Liste toutes les commandes (ADMIN)
GET http://localhost:8888/api/commandes/all
Authorization: Bearer <token>

# Récupère une commande
GET http://localhost:8888/api/commandes/{id}
Authorization: Bearer <token>
```

## 🔒 Sécurité

### Authentification et Autorisation

- **OAuth2/OpenID Connect**: via Keycloak
- **JWT**: Tokens signés et validés
- **Rôles**: ADMIN et CLIENT
- **Propagation de tokens**: JWT propagé entre microservices

### Règles de sécurité

#### API Gateway
- Valide tous les tokens JWT
- Route les requêtes vers les microservices
- Applique les règles d'autorisation au niveau gateway

#### Microservices
- Valident également les tokens JWT
- Appliquent les annotations `@PreAuthorize`
- Journalisent tous les accès avec l'identité utilisateur

### Communication inter-services

- Le service Commande appelle le service Produit via Feign
- Le token JWT est automatiquement propagé (FeignClientInterceptor)
- Vérification de disponibilité des produits avant création de commande

## 🔍 DevSecOps

Le projet intègre plusieurs outils de sécurité:

### Analyse statique (SonarQube)
```bash
sonar-scanner
```

### Analyse des dépendances (OWASP)
```bash
cd Produit
mvn org.owasp:dependency-check-maven:check
```

### Scan des images Docker (Trivy)
```bash
trivy image mini-projet-produit-service:latest
```

### Script automatique
```bash
./.devsecops/security-scan.sh
```

Voir `.devsecops/README.md` pour plus de détails.

## 📚 Documentation API

### Swagger/OpenAPI

Les API sont documentées avec Swagger:
- Service Produit: http://localhost:8081/swagger-ui.html
- Service Commande: http://localhost:8082/swagger-ui.html
- API Gateway: http://localhost:8888/swagger-ui.html

## 🧪 Tests

### Tests unitaires

```bash
# Service Produit
cd Produit
mvn test

# Service Commande
cd Commande
mvn test

# API Gateway
cd Api-gateway
mvn test
```

### Tests d'intégration

```bash
mvn verify
```

## 📊 Monitoring et Logs

### Logs applicatifs

Les logs sont configurés avec SLF4J et incluent:
- Logs d'accès aux APIs
- Logs d'erreurs applicatives
- Identification de l'utilisateur dans chaque log
- Logs des appels inter-services

### Actuator

Les endpoints Actuator sont disponibles:
- `/actuator/health`: État de santé du service
- `/actuator/info`: Informations sur l'application

## 🚢 Déploiement

### Docker Compose (Production)

```bash
docker-compose -f docker-compose.yml up -d
```

### Kubernetes (Extension)

Des manifests Kubernetes peuvent être ajoutés pour un déploiement cloud-native.

## 🔧 Dépannage

### Problème: Keycloak ne démarre pas
- Vérifiez que le port 8180 est libre
- Attendez 30-60 secondes pour le démarrage complet

### Problème: Services ne peuvent pas se connecter à Keycloak
- Vérifiez que le realm et le client sont correctement configurés
- Vérifiez les URLs dans les fichiers application.properties

### Problème: Erreur 401/403
- Vérifiez que vous êtes bien authentifié
- Vérifiez que votre utilisateur a le bon rôle
- Vérifiez que le token JWT n'est pas expiré

### Problème: Service Commande ne peut pas appeler Service Produit
- Vérifiez que les deux services sont démarrés
- Vérifiez la configuration `produit.service.url`
- Vérifiez les logs pour voir le détail de l'erreur

## 📄 Licence

Ce projet est développé à des fins éducatives.

## 👥 Auteurs

- Nouhayla AMOUHAL

## 🙏 Remerciements

- Spring Boot Team
- Keycloak Team
- React Team
