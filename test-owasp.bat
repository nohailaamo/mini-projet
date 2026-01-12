@echo off
REM Script PowerShell pour tester OWASP Dependency-Check

echo.
echo =====================================================
echo OWASP Dependency-Check - Test de vulnerabilites
echo =====================================================
echo.

echo [1] Scan du service Produit...
cd "C:\Users\Asus\Downloads\Mini Projet AMOUHAL\Produit"
call mvnw.cmd dependency-check:check -q

if errorlevel 0 (
    echo [OK] Scan Produit termine
    if exist target\dependency-check\dependency-check-report.html (
        echo [OK] Rapport HTML genere : target\dependency-check\dependency-check-report.html
        echo Ouvrir: C:\Users\Asus\Downloads\Mini Projet AMOUHAL\Produit\target\dependency-check\dependency-check-report.html
    )
) else (
    echo [ERREUR] Scan Produit echoue
)

echo.
echo [2] Scan du service Commande...
cd "C:\Users\Asus\Downloads\Mini Projet AMOUHAL\Commande"
call mvnw.cmd dependency-check:check -q

if errorlevel 0 (
    echo [OK] Scan Commande termine
    if exist target\dependency-check\dependency-check-report.html (
        echo [OK] Rapport HTML genere : target\dependency-check\dependency-check-report.html
        echo Ouvrir: C:\Users\Asus\Downloads\Mini Projet AMOUHAL\Commande\target\dependency-check\dependency-check-report.html
    )
) else (
    echo [ERREUR] Scan Commande echoue
)

echo.
echo =====================================================
echo Test termine!
echo =====================================================
echo.
echo Resultats :
echo - Produit : C:\Users\Asus\Downloads\Mini Projet AMOUHAL\Produit\target\dependency-check\
echo - Commande : C:\Users\Asus\Downloads\Mini Projet AMOUHAL\Commande\target\dependency-check\
echo.
pause

