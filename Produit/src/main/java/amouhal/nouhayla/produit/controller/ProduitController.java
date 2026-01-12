package amouhal.nouhayla.produit.controller;
import amouhal.nouhayla.produit.entity.Produit;
import amouhal.nouhayla.produit.service.ProduitService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:8888"})
@RequestMapping("/api/produits")
public class ProduitController {

    private static final Logger logger = LoggerFactory.getLogger(ProduitController.class);

    @Autowired
    private ProduitService produitService;

    // ADMIN : Ajouter
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping
    public ResponseEntity<Produit> ajouterProduit(@RequestBody Produit produit,
                                                  @AuthenticationPrincipal Jwt jwt) {
        String username = jwt.getClaimAsString("preferred_username");
        logger.info("Admin {} ajoute un nouveau produit: {}", username, produit.getNom());
        return ResponseEntity.ok(produitService.ajouterProduit(produit));
    }

    // ADMIN : Modifier
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}")
    public ResponseEntity<Produit> modifierProduit(@PathVariable Long id, @RequestBody Produit produit,
                                                   @AuthenticationPrincipal Jwt jwt) {
        String username = jwt.getClaimAsString("preferred_username");
        logger.info("Admin {} modifie le produit ID: {}", username, id);
        Produit updated = produitService.modifierProduit(id, produit);
        if (updated != null)
            return ResponseEntity.ok(updated);
        return ResponseEntity.notFound().build();
    }

    // ADMIN : Supprimer
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> supprimerProduit(@PathVariable Long id,
                                                @AuthenticationPrincipal Jwt jwt) {
        String username = jwt.getClaimAsString("preferred_username");
        logger.info("Admin {} supprime le produit ID: {}", username, id);
        produitService.supprimerProduit(id);
        return ResponseEntity.noContent().build();
    }

    // ADMIN & CLIENT : Lister
    @PreAuthorize("hasAnyRole('ADMIN','CLIENT')")
    @GetMapping
    public ResponseEntity<List<Produit>> listerProduits(@AuthenticationPrincipal Jwt jwt) {
        String username = jwt.getClaimAsString("preferred_username");
        logger.info("Utilisateur {} consulte la liste des produits", username);
        return ResponseEntity.ok(produitService.listerProduits());
    }

    // ADMIN & CLIENT : Consulter par ID
    @PreAuthorize("hasAnyRole('ADMIN','CLIENT')")
    @GetMapping("/{id}")
    public ResponseEntity<Produit> consulterProduit(@PathVariable Long id,
                                                    @AuthenticationPrincipal Jwt jwt) {
        String username = jwt.getClaimAsString("preferred_username");
        logger.info("Utilisateur {} consulte le produit ID: {}", username, id);
        return produitService.consulterProduit(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}