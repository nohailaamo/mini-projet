# Diagramme de Séquence - Processus de Commande

Ce document décrit le flux complet de création d'une commande dans le système.

## Scénario: Création d'une commande par un CLIENT

```
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│ Client   │  │ Frontend │  │   API    │  │ Keycloak │  │ Commande │  │ Produit  │
│(Browser) │  │  React   │  │ Gateway  │  │          │  │ Service  │  │ Service  │
└────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘
     │             │              │              │              │              │
     │ 1. Clic    │              │              │              │              │
     │"Commander" │              │              │              │              │
     ├────────────►│              │              │              │              │
     │             │              │              │              │              │
     │             │ 2. Vérifier │              │              │              │
     │             │    JWT Token│              │              │              │
     │             ├─────────────►│              │              │              │
     │             │              │              │              │              │
     │             │ 3. Token    │              │              │              │
     │             │    valide?  │              │              │              │
     │             │◄─────────────┤              │              │              │
     │             │              │              │              │              │
     │             │ Si invalide: │              │              │              │
     │             │ Redirection →├─────────────►│              │              │
     │             │    vers      │ Authentifier│              │              │
     │             │  Keycloak    │◄─────────────┤              │              │
     │             │              │ JWT Token   │              │              │
     │             │              │              │              │              │
     │             │ 4. POST /api/commandes     │              │              │
     │             │    Body: {lignes: [...]}   │              │              │
     │             │    Header: Authorization:  │              │              │
     │             │           Bearer <JWT>     │              │              │
     │             ├────────────►│              │              │              │
     │             │              │              │              │              │
     │             │              │ 5. Valider  │              │              │
     │             │              │    JWT      │              │              │
     │             │              ├─────────────►│              │              │
     │             │              │              │              │              │
     │             │              │ 6. JWT OK   │              │              │
     │             │              │    + Claims │              │              │
     │             │              │◄─────────────┤              │              │
     │             │              │              │              │              │
     │             │              │ 7. Vérifier │              │              │
     │             │              │    rôle     │              │              │
     │             │              │    CLIENT   │              │              │
     │             │              │    ✓        │              │              │
     │             │              │              │              │              │
     │             │              │ 8. Router vers Commande   │              │
     │             │              │    POST /api/commandes    │              │
     │             │              │    + JWT propagé          │              │
     │             │              ├─────────────┼─────────────►│              │
     │             │              │              │              │              │
     │             │              │              │              │ 9. Extraire│
     │             │              │              │              │   username │
     │             │              │              │              │   du JWT   │
     │             │              │              │              │            │
     │             │              │              │              │10. Pour    │
     │             │              │              │              │   chaque   │
     │             │              │              │              │   ligne:   │
     │             │              │              │              │            │
     │             │              │              │              │ 11. GET    │
     │             │              │              │              │   /api/    │
     │             │              │              │              │   produits/│
     │             │              │              │              │   {id}     │
     │             │              │              │              │   + JWT    │
     │             │              │              │              ├───────────►│
     │             │              │              │              │            │
     │             │              │              │              │ 12. Valider│
     │             │              │              │              │     JWT    │
     │             │              │              │              │◄───────────┤
     │             │              │              │              │            │
     │             │              │              │              │ 13. Retour │
     │             │              │              │              │    Produit │
     │             │              │              │              │    + Stock │
     │             │              │              │              │◄───────────┤
     │             │              │              │              │            │
     │             │              │              │              │14. Vérifier│
     │             │              │              │              │   stock    │
     │             │              │              │              │   suffisant│
     │             │              │              │              │            │
     │             │              │              │              │ Si stock   │
     │             │              │              │              │ insuffisant│
     │             │              │              │              │ → Exception│
     │             │              │              │              │            │
     │             │              │              │              │15. Calculer│
     │             │              │              │              │   montant  │
     │             │              │              │              │   total    │
     │             │              │              │              │            │
     │             │              │              │              │16. Créer   │
     │             │              │              │              │   commande │
     │             │              │              │              │   en DB    │
     │             │              │              │              │            │
     │             │              │              │              │17. Logger  │
     │             │              │              │              │   création │
     │             │              │              │              │            │
     │             │              │ 18. Response: Commande    │              │
     │             │              │     créée (200 OK)        │              │
     │             │              │◄─────────────┼─────────────┤              │
     │             │              │              │              │              │
     │             │ 19. Response │              │              │              │
     │             │    Commande │              │              │              │
     │             │◄────────────┤              │              │              │
     │             │              │              │              │              │
     │20. Afficher│              │              │              │              │
     │ confirmation│              │              │              │              │
     │◄────────────┤              │              │              │              │
     │             │              │              │              │              │
```

## Détails des Étapes

### Phase 1: Authentification (Étapes 1-3)
1. L'utilisateur clique sur "Commander" dans le frontend
2. Le frontend vérifie la présence et validité du JWT token
3. Si le token est invalide ou expiré, redirection vers Keycloak pour authentification

### Phase 2: Validation au Gateway (Étapes 4-7)
4. Le frontend envoie une requête POST avec le token JWT dans le header
5. L'API Gateway valide le token avec Keycloak
6. Keycloak confirme la validité et retourne les claims (username, rôles)
7. Le Gateway vérifie que l'utilisateur a le rôle CLIENT

### Phase 3: Routage vers le Service (Étape 8)
8. L'API Gateway route la requête vers le microservice Commande en propageant le JWT

### Phase 4: Traitement de la Commande (Étapes 9-16)
9. Le service Commande extrait le username du token JWT
10-13. Pour chaque produit dans la commande:
   - Appel au service Produit via Feign Client (avec propagation JWT)
   - Le service Produit valide le JWT
   - Retour des informations produit (prix, stock)
14. Vérification que le stock est suffisant (sinon exception)
15. Calcul du montant total de la commande
16. Création de la commande en base de données
17. Logging de l'opération avec identification de l'utilisateur

### Phase 5: Réponse (Étapes 18-20)
18. Le service Commande retourne la commande créée au Gateway
19. Le Gateway retourne la réponse au frontend
20. Le frontend affiche une confirmation à l'utilisateur

## Gestion des Erreurs

### Erreur 401 (Non autorisé)
```
Frontend → API Gateway → JWT invalide → 401 → Frontend → Redirect Keycloak
```

### Erreur 403 (Interdit)
```
Frontend → API Gateway → Utilisateur sans rôle CLIENT → 403 → Frontend → Message d'erreur
```

### Erreur 400 (Stock insuffisant)
```
Commande Service → Produit Service → Stock insuffisant → Exception
                                                           ↓
Commande Service → 400 Bad Request → Gateway → Frontend
                                                   ↓
                                          Afficher erreur
```

### Erreur 404 (Produit non trouvé)
```
Commande Service → Produit Service → Produit inexistant → 404
                                                            ↓
Commande Service → Exception → 400 → Gateway → Frontend
                                                   ↓
                                          Afficher erreur
```

## Logs Générés

### Dans le Service Commande
```
INFO  - Utilisateur client crée une nouvelle commande
INFO  - Produit Laptop ajouté à la commande. Quantité: 2, Prix: 999.99
INFO  - Commande 123 créée avec succès. Montant total: 1999.98
```

### Dans le Service Produit
```
INFO  - Utilisateur client consulte le produit ID: 1
```

### Dans l'API Gateway
```
INFO  - Request: POST /api/commandes from user: client
INFO  - Routing to commande-service
```

## Caractéristiques de Sécurité

1. ✅ Token JWT requis à chaque étape
2. ✅ Validation du token par Keycloak
3. ✅ Vérification des rôles (CLIENT requis)
4. ✅ Propagation du token dans les appels inter-services
5. ✅ Isolation des données (un client ne voit que ses commandes)
6. ✅ Traçabilité complète (logs avec identification utilisateur)
7. ✅ Validation métier (stock, produit existant)
8. ✅ Aucun accès direct aux microservices (via Gateway uniquement)

## Performance

- **Temps de réponse typique**: 200-500ms
- **Optimisations**:
  - Validation JWT mise en cache
  - Communication synchrone REST (peut être améliorée avec messaging asynchrone)
  - Index sur les bases de données
  - Health checks pour garantir disponibilité
