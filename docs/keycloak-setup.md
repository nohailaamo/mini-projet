# Guide de Configuration Keycloak

Ce guide détaille la configuration complète de Keycloak pour l'application microservices.

## Accès à Keycloak

- URL Admin: http://localhost:8180
- Username: `admin`
- Password: `admin`

## 1. Création du Realm

1. Connectez-vous à la console admin de Keycloak
2. Cliquez sur le menu déroulant en haut à gauche (où il est écrit "master")
3. Cliquez sur "Create Realm"
4. Remplissez les champs:
   - **Realm name**: `microservices-app`
   - **Enabled**: ON
5. Cliquez sur "Create"

## 2. Configuration du Client Frontend

### Créer le Client

1. Dans le realm `microservices-app`, allez dans **Clients**
2. Cliquez sur "Create client"
3. Remplissez:
   - **Client type**: OpenID Connect
   - **Client ID**: `frontend-client`
4. Cliquez sur "Next"

### Configuration du Client

5. Dans l'onglet "Settings":
   - **Client authentication**: OFF (public client)
   - **Standard flow**: Enabled
   - **Direct access grants**: Enabled
   - **Valid redirect URIs**: 
     ```
     http://localhost:3000/*
     http://localhost/*
     ```
   - **Valid post logout redirect URIs**:
     ```
     http://localhost:3000/*
     ```
   - **Web origins**:
     ```
     http://localhost:3000
     http://localhost
     ```
6. Cliquez sur "Save"

### Configuration des Roles

7. Dans l'onglet "Roles":
   - Cliquez sur "Add role"
   - Ne créez PAS de rôles ici (nous utilisons les realm roles)

## 3. Création des Realm Roles

1. Allez dans **Realm roles**
2. Cliquez sur "Create role"
3. Créez le rôle **ADMIN**:
   - **Role name**: `ADMIN`
   - **Description**: `Administrateur du système`
   - Cliquez sur "Save"
4. Créez le rôle **CLIENT**:
   - **Role name**: `CLIENT`
   - **Description**: `Client/Utilisateur standard`
   - Cliquez sur "Save"

## 4. Création des Utilisateurs

### Utilisateur Admin

1. Allez dans **Users**
2. Cliquez sur "Add user"
3. Remplissez:
   - **Username**: `admin`
   - **Email**: `admin@test.com`
   - **First name**: `Admin`
   - **Last name**: `User`
   - **Email verified**: ON
   - **Enabled**: ON
4. Cliquez sur "Create"

#### Définir le mot de passe

5. Allez dans l'onglet **Credentials**
6. Cliquez sur "Set password"
7. Remplissez:
   - **Password**: `admin`
   - **Password confirmation**: `admin`
   - **Temporary**: OFF (important!)
8. Cliquez sur "Save"

#### Assigner le rôle ADMIN

9. Allez dans l'onglet **Role mappings**
10. Cliquez sur "Assign role"
11. Sélectionnez le rôle `ADMIN`
12. Cliquez sur "Assign"

### Utilisateur Client

1. Retournez dans **Users** et cliquez sur "Add user"
2. Remplissez:
   - **Username**: `client`
   - **Email**: `client@test.com`
   - **First name**: `Client`
   - **Last name**: `User`
   - **Email verified**: ON
   - **Enabled**: ON
3. Cliquez sur "Create"

#### Définir le mot de passe

4. Allez dans l'onglet **Credentials**
5. Cliquez sur "Set password"
6. Remplissez:
   - **Password**: `client`
   - **Password confirmation**: `client`
   - **Temporary**: OFF (important!)
7. Cliquez sur "Save"

#### Assigner le rôle CLIENT

8. Allez dans l'onglet **Role mappings**
9. Cliquez sur "Assign role"
10. Sélectionnez le rôle `CLIENT`
11. Cliquez on "Assign"

## 5. Configuration des Token Settings (Optionnel)

Pour ajuster la durée de vie des tokens:

1. Allez dans **Realm settings**
2. Cliquez sur l'onglet **Tokens**
3. Ajustez les valeurs:
   - **Access Token Lifespan**: 5 minutes (par défaut)
   - **Access Token Lifespan For Implicit Flow**: 15 minutes
   - **Client login timeout**: 5 minutes
   - **SSO Session Idle**: 30 minutes
   - **SSO Session Max**: 10 hours

## 6. Vérification de la Configuration

### Test de connexion avec curl

```bash
# Obtenir un token pour l'admin
curl -X POST 'http://localhost:8180/realms/microservices-app/protocol/openid-connect/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'client_id=frontend-client' \
  -d 'username=admin' \
  -d 'password=admin' \
  -d 'grant_type=password'

# Obtenir un token pour le client
curl -X POST 'http://localhost:8180/realms/microservices-app/protocol/openid-connect/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'client_id=frontend-client' \
  -d 'username=client' \
  -d 'password=client' \
  -d 'grant_type=password'
```

### Vérifier les rôles dans le token

1. Copiez le `access_token` du résultat précédent
2. Allez sur https://jwt.io
3. Collez le token dans le décodeur
4. Vérifiez que la section `realm_access.roles` contient le bon rôle

Exemple de payload JWT pour admin:
```json
{
  "realm_access": {
    "roles": ["ADMIN"]
  },
  "preferred_username": "admin",
  "email": "admin@test.com"
}
```

## 7. Configuration pour Production

### Sécuriser Keycloak

1. **Changer les mots de passe par défaut**
2. **Activer HTTPS**: 
   - Configurer un certificat SSL
   - Mettre `KC_HOSTNAME_STRICT=true`
3. **Configurer une base de données externe**: PostgreSQL en production
4. **Activer la vérification d'email**: Pour la validation des comptes
5. **Configurer le Rate Limiting**: Protection contre les attaques par force brute

### Variables d'environnement pour production

```yaml
KEYCLOAK_ADMIN: ${ADMIN_USERNAME}
KEYCLOAK_ADMIN_PASSWORD: ${ADMIN_PASSWORD}
KC_HOSTNAME: your-domain.com
KC_HOSTNAME_STRICT: true
KC_PROXY: edge
KC_HTTP_ENABLED: false
KC_HTTPS_ENABLED: true
KC_HTTPS_CERTIFICATE_FILE: /path/to/cert.pem
KC_HTTPS_CERTIFICATE_KEY_FILE: /path/to/key.pem
```

## 8. Utilisateurs Supplémentaires (Optionnel)

Pour créer plus d'utilisateurs de test, répétez les étapes de la section 4 avec différents usernames et assignez le rôle approprié (ADMIN ou CLIENT).

### Exemples d'utilisateurs additionnels

| Username | Password | Rôle | Description |
|----------|----------|------|-------------|
| admin2 | admin2 | ADMIN | Second administrateur |
| client2 | client2 | CLIENT | Second client |
| testclient | test123 | CLIENT | Client de test |

## 9. Intégration avec les Microservices

Les microservices sont déjà configurés pour utiliser Keycloak via les propriétés:

```properties
spring.security.oauth2.resourceserver.jwt.issuer-uri=http://localhost:8180/realms/microservices-app
spring.security.oauth2.resourceserver.jwt.jwk-set-uri=http://localhost:8180/realms/microservices-app/protocol/openid-connect/certs
```

Ces URLs permettent:
- La validation automatique des tokens JWT
- La récupération des clés publiques pour vérifier les signatures
- L'extraction des claims (username, rôles)

## 10. Dépannage

### Problème: "Invalid redirect URI"

**Solution**: Vérifiez que les URLs de redirection dans le client frontend-client incluent bien:
- `http://localhost:3000/*`
- `http://localhost/*`

### Problème: "Client not found"

**Solution**: Vérifiez que:
1. Le client ID est exactement `frontend-client`
2. Vous êtes dans le bon realm (`microservices-app`)

### Problème: "Invalid user credentials"

**Solution**: Vérifiez que:
1. Le mot de passe n'est pas défini comme "Temporary"
2. L'utilisateur est activé (Enabled: ON)
3. Le username et password sont corrects

### Problème: Token expiré rapidement

**Solution**: Augmentez la durée de vie des tokens dans Realm Settings → Tokens → Access Token Lifespan

## 11. Export/Import de Configuration

### Exporter la configuration

```bash
docker exec -it keycloak /opt/keycloak/bin/kc.sh export \
  --dir /tmp/keycloak-export \
  --realm microservices-app
```

### Importer la configuration

```bash
docker exec -it keycloak /opt/keycloak/bin/kc.sh import \
  --dir /tmp/keycloak-export
```

## Résumé

Après avoir suivi ce guide, vous aurez:
- ✅ Un realm `microservices-app` configuré
- ✅ Un client `frontend-client` pour l'application React
- ✅ Deux rôles: ADMIN et CLIENT
- ✅ Deux utilisateurs de test: admin/admin et client/client
- ✅ Configuration JWT fonctionnelle pour tous les microservices

Vous pouvez maintenant démarrer l'application complète avec `docker-compose up --build`
