# Corrections apportées au projet

## Problème initial
Lorsque l'utilisateur démarrait l'application en local, le frontend se connectait correctement via Keycloak, mais les produits et les commandes ne s'affichaient pas, avec l'erreur : "Erreur lors du chargement des produits".

## Causes identifiées

### 1. Décalage de port Keycloak
**Problème** : Le fichier `docker-compose.yml` exposait Keycloak sur le port `8080:8080`, mais tous les services (Produit, Commande, API Gateway) et le frontend étaient configurés pour accéder à Keycloak sur le port `8180`.

**Impact** : Les services backend ne pouvaient pas valider les tokens JWT car ils ne pouvaient pas contacter Keycloak pour récupérer les clés de signature.

**Solution** : Modification du mapping de port dans `docker-compose.yml` de `8080:8080` à `8180:8080`.

### 2. Configuration réseau manquante pour Keycloak
**Problème** : Le service Keycloak dans `docker-compose.yml` n'avait pas de configuration `networks`, ce qui l'empêchait de communiquer avec sa base de données `keycloak-db`.

**Impact** : Keycloak ne pouvait pas démarrer car il ne pouvait pas se connecter à sa base de données PostgreSQL.

**Solution** : Ajout de la configuration `networks: - microservices-network` au service Keycloak.

### 3. Décalage de port de base de données Produit
**Problème** : Le service Produit dans `docker-compose.yml` expose la base de données sur le port `5434:5432`, mais `Produit/src/main/resources/application.properties` était configuré pour se connecter au port `5433`.

**Impact** : Le service Produit ne pouvait pas se connecter à sa base de données.

**Solution** : Modification de l'URL de connexion dans `application.properties` de `jdbc:postgresql://localhost:5433/produitdb` à `jdbc:postgresql://localhost:5434/produitdb`.

### 4. Absence de données initiales
**Problème** : Aucune donnée de produit n'était initialisée au démarrage de l'application.

**Impact** : Même si les services fonctionnaient correctement, la liste des produits était vide.

**Solution** : Création d'un composant `DataInitializer` qui ajoute automatiquement 8 produits d'exemple au démarrage si la base de données est vide.

### 5. Configuration de sécurité incomplète dans API Gateway
**Problème** : L'API Gateway ne configurait pas correctement le convertisseur JWT pour extraire les rôles Keycloak.

**Impact** : Même avec un token valide, les autorisations basées sur les rôles (ADMIN/CLIENT) ne fonctionnaient pas correctement.

**Solution** : 
- Ajout du `JwtAuthenticationConverter` avec le `KeycloakRealmRoleConverter` dans `SecurityConfig`
- Intégration de la configuration CORS directement dans `SecurityConfig`
- Suppression du fichier `CorsConfig.java` redondant

## Fichiers modifiés

### 1. docker-compose.yml
**Changement 1 - Port Keycloak:**
```yaml
# Avant
ports: [ "8080:8080" ]

# Après
ports: [ "8180:8080" ]
```

**Changement 2 - Réseau Keycloak:**
```yaml
# Avant
  keycloak:
    ...
    healthcheck:
      ...

# Après
  keycloak:
    ...
    networks:
      - microservices-network
    healthcheck:
      ...
```

### 2. Produit/src/main/resources/application.properties
```properties
# Avant
spring.datasource.url=jdbc:postgresql://localhost:5433/produitdb

# Après
spring.datasource.url=jdbc:postgresql://localhost:5434/produitdb
```

### 3. Nouveau fichier : Produit/src/main/java/amouhal/nouhayla/produit/config/DataInitializer.java
- Composant Spring qui s'exécute au démarrage
- Vérifie si la base de données est vide
- Initialise 8 produits d'exemple avec des noms, descriptions, prix et quantités réalistes

### 4. Api-gateway/src/main/java/amouhal/nouhayla/apigateway/config/SecurityConfig.java
- Ajout du `JwtAuthenticationConverter` pour extraire correctement les rôles
- Intégration de la configuration CORS
- Amélioration de la chaîne de filtres de sécurité

### 5. Suppression : Api-gateway/src/main/java/amouhal/nouhayla/apigateway/config/CorsConfig.java
- Fichier redondant, CORS maintenant géré dans SecurityConfig

## Résultat

Après ces corrections :
1. ✅ Keycloak est accessible sur le port correct (8180)
2. ✅ Tous les services backend peuvent se connecter à Keycloak
3. ✅ Les tokens JWT sont correctement validés
4. ✅ Les rôles ADMIN et CLIENT sont correctement extraits et appliqués
5. ✅ Les services se connectent à leurs bases de données respectives
6. ✅ La liste des produits affiche 8 produits d'exemple au démarrage
7. ✅ CORS fonctionne correctement entre le frontend (port 3000) et l'API Gateway (port 8888)

## Vérification

Pour vérifier que tout fonctionne :

```bash
# Démarrer les bases de données et Keycloak
docker compose up -d produit-db commande-db keycloak-db keycloak

# Attendre que Keycloak démarre complètement (environ 30-60 secondes)
# Vérifier que Keycloak est prêt
curl http://localhost:8180/realms/master

# Dans des terminaux séparés, démarrer les services :
cd Produit && mvn spring-boot:run
cd Commande && mvn spring-boot:run
cd Api-gateway && mvn spring-boot:run
cd frontend && npm install && npm start

# L'application devrait maintenant être accessible sur http://localhost:3000
```

## Note importante

Assurez-vous que Keycloak est configuré avec :
- Un realm nommé `microservices-app`
- Un client nommé `frontend-client` 
- Deux rôles : `ADMIN` et `CLIENT`
- Des utilisateurs de test avec les rôles appropriés

Consultez le fichier `docs/keycloak-setup.md` pour les instructions détaillées de configuration de Keycloak.
