package amouhal.nouhayla.commande.controller;
import amouhal.nouhayla.commande.entity.Commande;
import amouhal.nouhayla.commande.service.CommandeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/commandes")
public class CommandeController {

    @Autowired
    private CommandeService commandeService;

    // CLIENT: Créer une commande
    @PostMapping
    public ResponseEntity<Commande> createCommande(@RequestBody Commande commande,
                                                   @AuthenticationPrincipal Jwt jwt) {
        String username = jwt.getClaimAsString("preferred_username");
        commande.setClientUsername(username);
        Commande savedCommande = commandeService.createCommande(commande);
        return ResponseEntity.ok(savedCommande);
    }

    // CLIENT: Voir ses propres commandes
    @GetMapping
    public ResponseEntity<List<Commande>> getMesCommandes(@AuthenticationPrincipal Jwt jwt) {
        String username = jwt.getClaimAsString("preferred_username");
        List<Commande> mesCommandes = commandeService.getCommandesByClient(username);
        return ResponseEntity.ok(mesCommandes);
    }

    // ADMIN: Voir toutes les commandes
    @GetMapping("/all")
    public ResponseEntity<List<Commande>> getAllCommandes() {
        List<Commande> allCommandes = commandeService.getAllCommandes();
        return ResponseEntity.ok(allCommandes);
    }

    // Tous: Voir une commande par son id
    @GetMapping("/{id}")
    public ResponseEntity<Commande> getCommande(@PathVariable Long id) {
        Optional<Commande> commande = commandeService.getCommande(id);
        return commande.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }
}