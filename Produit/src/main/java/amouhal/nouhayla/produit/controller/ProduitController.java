package amouhal.nouhayla.produit.controller;
import amouhal.nouhayla.produit.entity.Produit;
import amouhal.nouhayla.produit.service.ProduitService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/produits")
public class ProduitController {

    @Autowired
    private ProduitService produitService;

    // ADMIN : Ajouter
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping
    public ResponseEntity<Produit> ajouterProduit(@RequestBody Produit produit) {
        return ResponseEntity.ok(produitService.ajouterProduit(produit));
    }

    // ADMIN : Modifier
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}")
    public ResponseEntity<Produit> modifierProduit(@PathVariable Long id, @RequestBody Produit produit) {
        Produit updated = produitService.modifierProduit(id, produit);
        if (updated != null)
            return ResponseEntity.ok(updated);
        return ResponseEntity.notFound().build();
    }

    // ADMIN : Supprimer
    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> supprimerProduit(@PathVariable Long id) {
        produitService.supprimerProduit(id);
        return ResponseEntity.noContent().build();
    }

    // ADMIN & CLIENT : Lister
    @PreAuthorize("hasAnyRole('ADMIN','CLIENT')")
    @GetMapping
    public ResponseEntity<List<Produit>> listerProduits() {
        return ResponseEntity.ok(produitService.listerProduits());
    }

    // ADMIN & CLIENT : Consulter par ID
    @PreAuthorize("hasAnyRole('ADMIN','CLIENT')")
    @GetMapping("/{id}")
    public ResponseEntity<Produit> consulterProduit(@PathVariable Long id) {
        return produitService.consulterProduit(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}