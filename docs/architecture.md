# Diagramme d'Architecture Globale

## Architecture Générale

```
┌─────────────────────────────────────────────────────────────────┐
│                         Utilisateurs                              │
│                    (ADMIN / CLIENT)                              │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTPS
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Frontend React (Port 3000)                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  - Interface utilisateur responsive                       │   │
│  │  - Authentification Keycloak (OAuth2/OIDC)               │   │
│  │  - Gestion de session JWT                                │   │
│  │  - Adaptation selon rôle (ADMIN/CLIENT)                  │   │
│  │  - Gestion des erreurs (401, 403)                        │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTP + JWT Token
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              API Gateway (Spring Cloud Gateway)                  │
│                        Port 8888                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  - Point d'entrée unique                                  │   │
│  │  - Validation des tokens JWT                             │   │
│  │  - Routage vers microservices                            │   │
│  │  - Règles de sécurité centralisées                       │   │
│  │  - Aucune logique métier                                 │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────┬────────────────────────┬────────────────────────┘
               │                        │
               │ HTTP + JWT             │ HTTP + JWT
               │                        │
        ┌──────▼──────┐          ┌─────▼──────┐
        │             │          │            │
┌───────┴─────────────┴────┐ ┌──┴────────────┴─────────┐
│  Microservice Produit    │ │  Microservice Commande   │
│      Port 8081           │ │       Port 8082          │
│  ┌────────────────────┐  │ │  ┌────────────────────┐  │
│  │ Controllers        │  │ │  │ Controllers        │  │
│  │ - CRUD Produits    │  │ │  │ - Créer commande   │  │
│  │ - Validation       │◄─┼─┼──┤ - Lister commandes │  │
│  │ - Sécurité JWT     │  │ │  │ - Sécurité JWT     │  │
│  └────────┬───────────┘  │ │  └────────┬───────────┘  │
│           │              │ │           │              │
│  ┌────────▼───────────┐  │ │  ┌────────▼───────────┐  │
│  │ Services           │  │ │  │ Services           │  │
│  │ - Logique métier   │  │ │  │ - Vérification     │  │
│  │ - Logs             │  │ │  │   stock            │  │
│  └────────┬───────────┘  │ │  │ - Calcul total     │  │
│           │              │ │  │ - Logs             │  │
│  ┌────────▼───────────┐  │ │  └────────┬───────────┘  │
│  │ Repositories       │  │ │           │              │
│  │ - JPA              │  │ │  ┌────────▼───────────┐  │
│  └────────┬───────────┘  │ │  │ Repositories       │  │
│           │              │ │  │ - JPA              │  │
│           │              │ │  └────────┬───────────┘  │
└───────────┼──────────────┘ └───────────┼──────────────┘
            │                            │
            │ JDBC                       │ JDBC
            │                            │
     ┌──────▼──────┐              ┌─────▼──────┐
     │ PostgreSQL  │              │ PostgreSQL │
     │  Produit    │              │  Commande  │
     │ Port 5433   │              │ Port 5434  │
     └─────────────┘              └────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                  Serveur Keycloak (Port 8180)                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  - Authentification OAuth2/OpenID Connect                │   │
│  │  - Gestion des utilisateurs                              │   │
│  │  - Gestion des rôles (ADMIN, CLIENT)                     │   │
│  │  - Génération et validation des tokens JWT              │   │
│  │  - Single Sign-On (SSO)                                  │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                      ┌──────▼──────┐
                      │ PostgreSQL  │
                      │  Keycloak   │
                      └─────────────┘
```

## Flux de Données

### 1. Authentification
```
Utilisateur → Frontend → Keycloak → JWT Token → Frontend
```

### 2. Requête API avec Authentification
```
Frontend → API Gateway → Validation JWT → Microservice
         ↑             ↑
         │             └─ Keycloak (validation)
         │
         └─ JWT Token dans Header Authorization
```

### 3. Communication Inter-Services
```
Commande Service → Produit Service
       │                 │
       └─ JWT propagé ───┘
       └─ FeignClient avec Interceptor
```

## Principes de Sécurité

1. **Aucun accès direct aux microservices**: Toutes les requêtes passent par l'API Gateway
2. **Validation JWT à plusieurs niveaux**: Gateway + Microservices
3. **Autorisation basée sur les rôles**: @PreAuthorize sur chaque endpoint
4. **Propagation de tokens**: JWT transmis dans les appels inter-services
5. **Base de données isolées**: Chaque service a sa propre base de données
6. **Logs avec identification**: Chaque action est tracée avec l'utilisateur

## Technologies par Composant

| Composant | Technologie | Port |
|-----------|-------------|------|
| Frontend | React 18 + TypeScript | 3000 |
| API Gateway | Spring Cloud Gateway | 8888 |
| Service Produit | Spring Boot 4.0.1 | 8081 |
| Service Commande | Spring Boot 4.0.1 | 8082 |
| Keycloak | Keycloak 23.0 | 8180 |
| DB Produit | PostgreSQL 15 | 5433 |
| DB Commande | PostgreSQL 15 | 5434 |
| DB Keycloak | PostgreSQL 15 | (interne) |

## Déploiement

Tous les composants sont conteneurisés avec Docker et orchestrés via Docker Compose:
- Images Docker multi-stage pour optimisation
- Réseau Docker bridge pour isolation
- Volumes persistants pour les bases de données
- Health checks pour garantir la disponibilité
