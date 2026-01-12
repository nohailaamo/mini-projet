# Guide de Démarrage Rapide Local

## ✅ Problème Résolu

Le problème d'origine était que Docker Compose ne pouvait pas construire les images en raison de problèmes réseau ou de configuration. **Ce guide vous permet de contourner complètement Docker** pour le développement local.

## 🚀 Solutions Disponibles

### Solution 1 : H2 en mémoire (LA PLUS SIMPLE - Recommandée)

Aucune installation de base de données nécessaire !

```bash
# Étape 1 : Démarrer tous les services
./start-local.sh --h2

# Étape 2 : Démarrer le frontend (nouveau terminal)
cd frontend
npm install
npm start
```

**Accédez à l'application** : http://localhost:3000

**Avantages** :
- ✅ Pas besoin de Docker du tout
- ✅ Pas besoin de PostgreSQL
- ✅ Démarrage ultra-rapide
- ✅ Parfait pour le développement

**Inconvénients** :
- ⚠️ Données perdues au redémarrage
- ⚠️ Pas d'authentification Keycloak (sauf si démarré séparément)

### Solution 2 : PostgreSQL dans Docker (Bases de données uniquement)

Utilise Docker **uniquement** pour PostgreSQL, pas pour les services Java.

```bash
# Démarrer avec PostgreSQL dans Docker
./start-local.sh

# Démarrer le frontend (nouveau terminal)
cd frontend
npm install
npm start
```

**Avantages** :
- ✅ Services Java en local (facile à debugger)
- ✅ Données persistantes dans PostgreSQL
- ✅ Plus proche de la production

### Solution 3 : Complètement manuel

Pour plus de contrôle, démarrez chaque service individuellement :

#### Option A : Avec H2 (pas de BD)

```bash
# Terminal 1 - Service Produit
cd Produit
mvn spring-boot:run -Dspring-boot.run.profiles=h2

# Terminal 2 - Service Commande
cd Commande
mvn spring-boot:run -Dspring-boot.run.profiles=h2

# Terminal 3 - API Gateway
cd Api-gateway
mvn spring-boot:run

# Terminal 4 - Frontend
cd frontend
npm install && npm start
```

#### Option B : Avec PostgreSQL Docker

```bash
# Terminal 1 - Démarrer PostgreSQL
docker run -d --name produit-db -e POSTGRES_DB=produitdb \
  -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=admin \
  -p 5433:5432 postgres:15-alpine

docker run -d --name commande-db -e POSTGRES_DB=commandedb \
  -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=admin \
  -p 5434:5432 postgres:15-alpine

# Terminal 2 - Service Produit
cd Produit
mvn spring-boot:run

# Terminal 3 - Service Commande
cd Commande
mvn spring-boot:run

# Terminal 4 - API Gateway
cd Api-gateway
mvn spring-boot:run

# Terminal 5 - Frontend
cd frontend
npm install && npm start
```

## 🎯 Vérification

Une fois démarrés, vérifiez que tout fonctionne :

```bash
# Service Produit
curl http://localhost:8081/actuator/health

# Service Commande
curl http://localhost:8082/actuator/health

# API Gateway
curl http://localhost:8888/actuator/health

# Frontend
curl http://localhost:3000
```

## 🛑 Arrêter les services

### Avec le script automatique :
```bash
./stop-local.sh
```

### Manuellement :
- Ctrl+C dans chaque terminal
- Pour arrêter les conteneurs Docker PostgreSQL :
  ```bash
  docker stop produit-db commande-db
  docker rm produit-db commande-db
  ```

## 📊 URLs des Services

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | Interface utilisateur React |
| API Gateway | http://localhost:8888 | Point d'entrée API |
| Service Produit | http://localhost:8081 | Gestion des produits |
| Service Commande | http://localhost:8082 | Gestion des commandes |
| Swagger Produit | http://localhost:8081/swagger-ui.html | Documentation API Produit |
| Swagger Commande | http://localhost:8082/swagger-ui.html | Documentation API Commande |
| H2 Console Produit | http://localhost:8081/h2-console | Console BD Produit (si H2) |
| H2 Console Commande | http://localhost:8082/h2-console | Console BD Commande (si H2) |

## 🔧 Options du Script start-local.sh

```bash
# Utiliser H2 en mémoire (recommandé pour dev)
./start-local.sh --h2

# Avec Keycloak pour l'authentification
./start-local.sh --with-keycloak

# Sans Docker du tout (nécessite PostgreSQL local)
./start-local.sh --no-docker

# Ne pas recompiler les services
./start-local.sh --no-build

# Afficher l'aide
./start-local.sh --help
```

## 🐛 Dépannage

### Erreur "Port already in use"

```bash
# Trouver quel processus utilise le port
lsof -i :8081  # ou 8082, 8888, 3000

# Tuer le processus
kill -9 <PID>
```

### Erreur "Maven command not found"

Installez Maven :
- **Windows** : Téléchargez depuis https://maven.apache.org/download.cgi
- **macOS** : `brew install maven`
- **Linux** : `sudo apt install maven`

### Erreur "Java version"

Vous avez besoin de Java 17+. Vérifiez :
```bash
java -version
```

Installez Java 17 si nécessaire :
- **Windows** : Téléchargez depuis https://adoptium.net/
- **macOS** : `brew install openjdk@17`
- **Linux** : `sudo apt install openjdk-17-jdk`

### Les services ne se connectent pas entre eux

Vérifiez que tous les services sont bien démarrés :
```bash
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
curl http://localhost:8888/actuator/health
```

### Voir les logs

```bash
# Avec le script automatique
tail -f logs/produit.log
tail -f logs/commande.log
tail -f logs/gateway.log

# Manuellement
# Les logs s'affichent dans les terminaux où vous avez lancé les services
```

## 💡 Conseils de Développement

1. **Utilisez H2 pour le développement rapide** : Pas besoin de gérer PostgreSQL
2. **Démarrez les services dans l'ordre** : Bases de données → Services backend → API Gateway → Frontend
3. **Utilisez votre IDE favori** : IntelliJ IDEA, Eclipse, ou VS Code peuvent lancer les services directement
4. **Hot reload** : Les modifications de code Java nécessitent un redémarrage, mais React recharge automatiquement
5. **Console H2** : Utilisez http://localhost:8081/h2-console pour voir les données (JDBC URL: `jdbc:h2:mem:produitdb`, user: `sa`, no password)

## 📚 Documentation Complète

Pour plus de détails, consultez :
- **[LOCAL_SETUP.md](LOCAL_SETUP.md)** - Guide complet du développement local
- **[README.md](README.md)** - Documentation générale du projet
- **start-local.sh** - Script automatique (lisez le code pour comprendre)

## ✨ Résumé

**Vous pouvez maintenant développer sans Docker !** Utilisez la Solution 1 (H2) pour un démarrage rapide, ou la Solution 2 (PostgreSQL Docker) pour un environnement plus proche de la production.

Le problème Docker initial est complètement contourné. 🎉
