package amouhal.nouhayla.commande.controller;
import amouhal.nouhayla.commande.entity.Commande;
import amouhal.nouhayla.commande.service.CommandeService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@CrossOrigin(origins = "http://localhost:3001")
@RequestMapping("/api/commandes")
public class CommandeController {

    private static final Logger logger = LoggerFactory.getLogger(CommandeController.class);

    @Autowired
    private CommandeService commandeService;

    // CLIENT: Créer une commande
    @PreAuthorize("hasRole('CLIENT')")
    @PostMapping
    public ResponseEntity<Commande> createCommande(@RequestBody Commande commande,
                                                   @AuthenticationPrincipal Jwt jwt) {
        String username = jwt.getClaimAsString("preferred_username");
        logger.info("Utilisateur {} crée une nouvelle commande", username);
        commande.setClientUsername(username);
        try {
            Commande savedCommande = commandeService.createCommande(commande);
            logger.info("Commande {} créée avec succès par {}", savedCommande.getId(), username);
            return ResponseEntity.ok(savedCommande);
        } catch (Exception e) {
            logger.error("Erreur lors de la création de commande par {}: {}", username, e.getMessage());
            return ResponseEntity.badRequest().build();
        }
    }

    // CLIENT: Voir ses propres commandes
    @PreAuthorize("hasRole('CLIENT')")
    @GetMapping
    public ResponseEntity<List<Commande>> getMesCommandes(@AuthenticationPrincipal Jwt jwt) {
        String username = jwt.getClaimAsString("preferred_username");
        logger.info("Utilisateur {} consulte ses commandes", username);
        List<Commande> mesCommandes = commandeService.getCommandesByClient(username);
        return ResponseEntity.ok(mesCommandes);
    }

    // ADMIN: Voir toutes les commandes
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/all")
    public ResponseEntity<List<Commande>> getAllCommandes(@AuthenticationPrincipal Jwt jwt) {
        String username = jwt.getClaimAsString("preferred_username");
        logger.info("Admin {} consulte toutes les commandes", username);
        List<Commande> allCommandes = commandeService.getAllCommandes();
        return ResponseEntity.ok(allCommandes);
    }

    // Tous: Voir une commande par son id
    @PreAuthorize("hasAnyRole('CLIENT', 'ADMIN')")
    @GetMapping("/{id}")
    public ResponseEntity<Commande> getCommande(@PathVariable Long id,
                                                @AuthenticationPrincipal Jwt jwt) {
        String username = jwt.getClaimAsString("preferred_username");
        logger.info("Utilisateur {} consulte la commande {}", username, id);
        Optional<Commande> commande = commandeService.getCommande(id);
        return commande.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }
}