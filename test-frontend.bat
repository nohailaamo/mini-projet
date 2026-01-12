@echo off
REM Script de test pour vérifier que le frontend récupère bien les produits et commandes

echo.
echo =====================================================
echo Test de recuperation des donnees du Frontend
echo =====================================================
echo.

echo 1. Verification de Keycloak...
curl -s http://localhost:8180 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Keycloak est actif
) else (
    echo [ERREUR] Keycloak n'est pas actif
)
echo.

echo 2. Verification du Service Produit...
curl -s -H "Authorization: Bearer test" http://localhost:8081/api/produits >nul 2>&1
if %ERRORLEVEL% LEQ 1 (
    echo [OK] Service Produit repond
) else (
    echo [ERREUR] Service Produit n'est pas actif
)
echo.

echo 3. Verification du Service Commande...
curl -s -H "Authorization: Bearer test" http://localhost:8082/api/commandes >nul 2>&1
if %ERRORLEVEL% LEQ 1 (
    echo [OK] Service Commande repond
) else (
    echo [ERREUR] Service Commande n'est pas actif
)
echo.

echo 4. Verification de l'API Gateway...
curl -s -H "Authorization: Bearer test" http://localhost:8888/api/produits >nul 2>&1
if %ERRORLEVEL% LEQ 1 (
    echo [OK] API Gateway repond
) else (
    echo [ERREUR] API Gateway n'est pas actif
)
echo.

echo 5. Verification du Frontend...
curl -s http://localhost:3000 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Frontend est actif
) else (
    echo [ERREUR] Frontend n'est pas actif
)
echo.

echo =====================================================
echo Etapes pour tester le Frontend:
echo =====================================================
echo.
echo 1. Ouvrir http://localhost:3000 dans le navigateur
echo 2. Cliquer sur 'Se connecter'
echo 3. Se connecter avec:
echo    - Admin: admin / admin
echo    - Client: client / client
echo.
echo 4. Verifier que les produits s'affichent:
echo    - Page 'Produits' devrait afficher 8 produits
echo.
echo 5. Pour CLIENT - Verifier les commandes:
echo    - Aller a l'onglet 'Commandes'
echo    - Creer une nouvelle commande
echo    - Verifier qu'elle apparait dans la liste
echo.
echo 6. Pour ADMIN - Verifier toutes les commandes:
echo    - Aller a l'onglet 'Toutes les Commandes'
echo    - Devrait afficher toutes les commandes du systeme
echo.
echo =====================================================
echo Debugging (F12 - Console du navigateur):
echo =====================================================
echo.
echo Les logs suivants doivent apparaitre:
echo   [OK] 'Chargement des produits...'
echo   [OK] 'Produits recus: [...]'
echo   [OK] 'Chargement des commandes...'
echo   [OK] 'Commandes recus: [...]'
echo.
echo En cas d'erreur, chercher:
echo   [ERR] 'Erreur complete: {...}'
echo   [ERR] 'CORS error'
echo   [ERR] 'Unauthorized'
echo.

