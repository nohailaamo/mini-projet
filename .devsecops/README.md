# Guide DevSecOps

Ce dossier contient les outils et configurations pour l'analyse de sécurité du projet.

## Outils inclus

### 1. SonarQube
- **Objectif**: Analyse statique du code
- **Configuration**: `../sonar-project.properties`
- **Commande**: `sonar-scanner`
- **Résultats**: Dashboard SonarQube (nécessite un serveur SonarQube)

### 2. OWASP Dependency-Check
- **Objectif**: Analyse des vulnérabilités dans les dépendances
- **Configuration**: Intégré dans les POMs Maven
- **Commande Maven**: 
  ```bash
  cd Produit && mvn org.owasp:dependency-check-maven:check
  cd Commande && mvn org.owasp:dependency-check-maven:check
  cd Api-gateway && mvn org.owasp:dependency-check-maven:check
  ```
- **Résultats**: Rapports HTML dans `target/dependency-check-report.html`

### 3. Trivy
- **Objectif**: Scan des vulnérabilités dans les images Docker
- **Installation**: 
  - macOS: `brew install aquasecurity/trivy/trivy`
  - Linux: `apt-get install trivy`
- **Commande**: `trivy image <image-name>`
- **Résultats**: Fichiers texte dans `.devsecops/`

## Utilisation

### Script automatique
Exécutez tous les outils de sécurité en une seule commande:
```bash
./.devsecops/security-scan.sh
```

### Exécution manuelle

#### SonarQube
```bash
sonar-scanner
```

#### OWASP Dependency-Check
```bash
cd Produit
mvn org.owasp:dependency-check-maven:check
```

#### Trivy
```bash
docker-compose build
trivy image --severity HIGH,CRITICAL mini-projet-produit-service:latest
```

## Intégration CI/CD

### GitHub Actions
Ajoutez ces étapes à votre workflow:
```yaml
- name: OWASP Dependency Check
  run: mvn org.owasp:dependency-check-maven:check

- name: Trivy Scan
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ${{ env.IMAGE_NAME }}
    severity: 'CRITICAL,HIGH'
```

### GitLab CI
```yaml
security:
  stage: test
  script:
    - ./.devsecops/security-scan.sh
  artifacts:
    paths:
      - .devsecops/
```

## Rapports

Les rapports de sécurité sont générés dans ce dossier:
- `dependency-check-*/`: Rapports OWASP
- `trivy-*.txt`: Rapports Trivy
- Les résultats SonarQube sont disponibles sur le serveur SonarQube

## Bonnes pratiques

1. **Exécutez les scans avant chaque commit important**
2. **Corrigez les vulnérabilités CRITICAL immédiatement**
3. **Planifiez la correction des vulnérabilités HIGH**
4. **Documentez les faux positifs**
5. **Mettez à jour régulièrement les dépendances**

## Seuils de sécurité

- **CRITICAL**: Correction immédiate requise
- **HIGH**: Correction dans les 7 jours
- **MEDIUM**: Correction dans les 30 jours
- **LOW**: Correction dans les 90 jours
