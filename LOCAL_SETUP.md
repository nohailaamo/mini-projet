# Configuration Locale Sans Docker

Ce guide vous permet de lancer l'application complète **en local sans conteneurisation Docker** (sauf pour les bases de données PostgreSQL si nécessaire).

## 🎯 Objectif

Permettre de tester et développer le projet localement sans les problèmes de Docker, tout en gardant une configuration simple.

## 📋 Prérequis

### Obligatoire
- **Java 17 ou supérieur** (JDK)
- **Maven 3.8+**
- **Node.js 18+** et **npm**

### Optionnel (pour bases de données)
- **PostgreSQL 15** installé localement OU
- **Docker** (uniquement pour les bases de données)

## 🚀 Option 1 : Démarrage Rapide avec H2 (Base de données en mémoire)

Cette option est la plus simple - pas besoin de PostgreSQL !

### 1. Démarrer Keycloak (optionnel pour les tests de base)

Si vous n'avez pas besoin d'authentification pour vos tests :
- Vous pouvez désactiver temporairement la sécurité (voir section Configuration)

Si vous avez besoin de Keycloak :
```bash
# Démarrer uniquement Keycloak avec Docker
docker run -d \
  --name keycloak-local \
  -p 8180:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  quay.io/keycloak/keycloak:23.0 \
  start-dev
```

Puis configurez Keycloak selon le README principal.

### 2. Démarrer les services Spring Boot avec H2

```bash
# Service Produit (avec H2)
cd Produit
mvn spring-boot:run -Dspring-boot.run.profiles=h2

# Dans un autre terminal - Service Commande (avec H2)
cd Commande
mvn spring-boot:run -Dspring-boot.run.profiles=h2

# Dans un autre terminal - API Gateway
cd Api-gateway
mvn spring-boot:run
```

### 3. Démarrer le Frontend

```bash
cd frontend
npm install
npm start
```

L'application sera disponible sur :
- Frontend: http://localhost:3000
- API Gateway: http://localhost:8888
- Service Produit: http://localhost:8081
- Service Commande: http://localhost:8082

## 🚀 Option 2 : Avec PostgreSQL Local

### 1. Installer PostgreSQL localement

#### Sur Windows
Téléchargez et installez depuis : https://www.postgresql.org/download/windows/

#### Sur macOS
```bash
brew install postgresql@15
brew services start postgresql@15
```

#### Sur Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install postgresql-15
sudo systemctl start postgresql
```

### 2. Créer les bases de données

```bash
# Se connecter à PostgreSQL
psql -U postgres

# Créer les bases de données
CREATE DATABASE produitdb;
CREATE DATABASE commandedb;

# Créer l'utilisateur (si nécessaire)
CREATE USER postgres WITH PASSWORD 'admin';
GRANT ALL PRIVILEGES ON DATABASE produitdb TO postgres;
GRANT ALL PRIVILEGES ON DATABASE commandedb TO postgres;

# Quitter
\q
```

### 3. Configurer les ports PostgreSQL

Par défaut, PostgreSQL local utilise le port 5432. Modifiez les fichiers de configuration :

**Produit/src/main/resources/application.properties** :
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/produitdb
```

**Commande/src/main/resources/application.properties** :
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/commandedb
```

### 4. Démarrer les services

```bash
# Service Produit
cd Produit
mvn spring-boot:run

# Service Commande (nouveau terminal)
cd Commande
mvn spring-boot:run

# API Gateway (nouveau terminal)
cd Api-gateway
mvn spring-boot:run

# Frontend (nouveau terminal)
cd frontend
npm install
npm start
```

## 🚀 Option 3 : PostgreSQL avec Docker uniquement

Utilisez Docker **uniquement** pour les bases de données :

### 1. Démarrer PostgreSQL avec Docker

```bash
# PostgreSQL pour Produit
docker run -d \
  --name produit-db \
  -e POSTGRES_DB=produitdb \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=admin \
  -p 5433:5432 \
  postgres:15-alpine

# PostgreSQL pour Commande
docker run -d \
  --name commande-db \
  -e POSTGRES_DB=commandedb \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=admin \
  -p 5434:5432 \
  postgres:15-alpine

# Keycloak (optionnel)
docker run -d \
  --name keycloak-local \
  -p 8180:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  quay.io/keycloak/keycloak:23.0 \
  start-dev
```

### 2. Configurer les connexions

Les fichiers `application.properties` sont déjà configurés pour ces ports (5433 et 5434).

### 3. Démarrer les services Spring Boot

```bash
# Service Produit
cd Produit
mvn spring-boot:run

# Service Commande (nouveau terminal)
cd Commande
mvn spring-boot:run

# API Gateway (nouveau terminal)
cd Api-gateway
mvn spring-boot:run

# Frontend (nouveau terminal)
cd frontend
npm install
npm start
```

## 🛠️ Script Automatique

Utilisez le script fourni pour démarrer automatiquement :

```bash
./start-local.sh
```

Ce script :
1. Démarre PostgreSQL avec Docker (ports 5433 et 5434)
2. Démarre Keycloak avec Docker (port 8180)
3. Attend que les bases de données soient prêtes
4. Compile et démarre chaque microservice Spring Boot
5. Démarre le frontend React

## ⚙️ Configuration

### Désactiver l'authentification (pour tests)

Pour tester sans Keycloak, vous pouvez désactiver temporairement la sécurité :

**Dans chaque microservice** (Produit, Commande, Api-gateway), ajoutez cette classe :

```java
@Configuration
public class SecurityConfigDev {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.csrf().disable()
            .authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
        return http.build();
    }
}
```

### Utiliser H2 au lieu de PostgreSQL

Créez un profil H2 pour chaque service (voir les fichiers `application-h2.properties` créés).

## 🧪 Tests

### Tester les services individuellement

```bash
# Tester le service Produit
cd Produit
mvn test

# Tester le service Commande
cd Commande
mvn test

# Tester l'API Gateway
cd Api-gateway
mvn test
```

### Tester l'intégration

1. Démarrez tous les services localement
2. Accédez au frontend : http://localhost:3000
3. Testez les fonctionnalités

### Tester les API avec curl (sans authentification)

```bash
# Lister les produits
curl http://localhost:8081/api/produits

# Créer un produit
curl -X POST http://localhost:8081/api/produits \
  -H "Content-Type: application/json" \
  -d '{"nom":"Test","description":"Test produit","prix":99.99,"quantiteStock":10}'
```

## 🐛 Dépannage

### Port déjà utilisé

Si un port est déjà utilisé, modifiez-le dans `application.properties` :

```properties
server.port=8091  # Par exemple, au lieu de 8081
```

### Erreur de connexion à la base de données

- Vérifiez que PostgreSQL est démarré
- Vérifiez les credentials dans `application.properties`
- Vérifiez les ports (5432 pour PostgreSQL local, 5433/5434 pour Docker)

### Maven build error

```bash
# Nettoyer et reconstruire
cd <service>
mvn clean install -DskipTests
```

### Keycloak non disponible

Si vous n'avez pas besoin d'authentification, désactivez-la (voir Configuration).

### Services ne peuvent pas communiquer

Vérifiez que toutes les URLs dans `application.properties` pointent vers `localhost` avec les bons ports.

## 📊 Vérification

Pour vérifier que tout fonctionne :

```bash
# Vérifier les services
curl http://localhost:8081/actuator/health  # Produit
curl http://localhost:8082/actuator/health  # Commande
curl http://localhost:8888/actuator/health  # Gateway

# Vérifier le frontend
curl http://localhost:3000
```

## 🔄 Arrêter les services

### Services Spring Boot
Utilisez `Ctrl+C` dans chaque terminal

### Bases de données Docker
```bash
docker stop produit-db commande-db keycloak-local
docker rm produit-db commande-db keycloak-local
```

## 💡 Conseils

1. **Ordre de démarrage recommandé** :
   - Bases de données (PostgreSQL/H2)
   - Keycloak (si nécessaire)
   - Services backend (Produit, Commande)
   - API Gateway
   - Frontend

2. **Développement** : Utilisez H2 pour le développement rapide

3. **Tests d'intégration** : Utilisez PostgreSQL Docker pour être plus proche de la production

4. **IDE** : Vous pouvez aussi démarrer les services depuis votre IDE (IntelliJ IDEA, Eclipse, VS Code avec extension Java)

## 📝 Notes

- Cette configuration est idéale pour le développement et les tests locaux
- Pour la production, utilisez Docker Compose comme prévu initialement
- Les profils H2 utilisent des bases de données en mémoire (données perdues au redémarrage)
