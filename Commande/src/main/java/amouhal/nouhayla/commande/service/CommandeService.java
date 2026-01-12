package amouhal.nouhayla.commande.service;
import amouhal.nouhayla.commande.client.ProduitClient;
import amouhal.nouhayla.commande.client.ProduitDto;
import amouhal.nouhayla.commande.entity.Commande;
import amouhal.nouhayla.commande.entity.LigneCommande;
import amouhal.nouhayla.commande.repository.CommandeRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class CommandeService {
    public CommandeRepository getCommandeRepository() {
        return commandeRepository;
    }

    public void setCommandeRepository(CommandeRepository commandeRepository) {
        this.commandeRepository = commandeRepository;
    }

    public ProduitClient getProduitClient() {
        return produitClient;
    }

    public void setProduitClient(ProduitClient produitClient) {
        this.produitClient = produitClient;
    }

    private static final Logger logger = LoggerFactory.getLogger(CommandeService.class);

    @Autowired
    private CommandeRepository commandeRepository;

    @Autowired
    private ProduitClient produitClient;

    // Création
    public Commande createCommande(Commande commande) {
        logger.info("Création d'une commande pour le client: {}", commande.getClientUsername());
        
        commande.setDateCommande(LocalDateTime.now());
        double total = 0;
        
        if (commande.getLignes() != null) {
            for (LigneCommande ligne : commande.getLignes()) {
                // Vérifier la disponibilité du produit via le service Produit
                try {
                    ProduitDto produit = produitClient.getProduit(ligne.getProduitId());
                    
                    if (produit == null) {
                        logger.error("Produit {} non trouvé", ligne.getProduitId());
                        throw new RuntimeException("Produit " + ligne.getProduitId() + " non trouvé");
                    }
                    
                    if (produit.getQuantiteStock() < ligne.getQuantite()) {
                        logger.error("Stock insuffisant pour le produit {}. Demandé: {}, Disponible: {}", 
                            ligne.getProduitId(), ligne.getQuantite(), produit.getQuantiteStock());
                        throw new RuntimeException("Stock insuffisant pour le produit " + produit.getNom());
                    }
                    
                    // Utiliser le prix du produit
                    ligne.setPrix(produit.getPrix());
                    ligne.setCommande(commande);
                    total += (ligne.getPrix() * ligne.getQuantite());
                    
                    logger.info("Produit {} ajouté à la commande. Quantité: {}, Prix: {}", 
                        produit.getNom(), ligne.getQuantite(), produit.getPrix());
                } catch (Exception e) {
                    logger.error("Erreur lors de la vérification du produit {}: {}", ligne.getProduitId(), e.getMessage());
                    throw new RuntimeException("Erreur lors de la vérification du produit: " + e.getMessage());
                }
            }
        }
        
        commande.setMontantTotal(total);
        commande.setStatut("EN_COURS");
        
        Commande savedCommande = commandeRepository.save(commande);
        logger.info("Commande {} créée avec succès. Montant total: {}", savedCommande.getId(), total);
        
        return savedCommande;
    }

    public List<Commande> getCommandesByClient(String username) {
        logger.info("Récupération des commandes pour le client: {}", username);
        return commandeRepository.findByClientUsername(username);
    }

    public Optional<Commande> getCommande(Long id) {
        logger.info("Récupération de la commande: {}", id);
        return commandeRepository.findById(id);
    }

    public List<Commande> getAllCommandes() {
        logger.info("Récupération de toutes les commandes");
        return commandeRepository.findAll();
    }
}