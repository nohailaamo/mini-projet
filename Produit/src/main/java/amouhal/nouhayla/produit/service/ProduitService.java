package amouhal.nouhayla.produit.service;
import amouhal.nouhayla.produit.entity.Produit;
import amouhal.nouhayla.produit.repository.ProduitRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProduitService {

    private static final Logger logger = LoggerFactory.getLogger(ProduitService.class);

    @Autowired
    private ProduitRepository produitRepository;

    public Produit ajouterProduit(Produit produit) {
        logger.info("Ajout d'un nouveau produit: {}", produit.getNom());
        Produit saved = produitRepository.save(produit);
        logger.info("Produit ajouté avec ID: {}", saved.getId());
        return saved;
    }

    public Produit modifierProduit(Long id, Produit produit) {
        logger.info("Modification du produit ID: {}", id);
        Optional<Produit> existing = produitRepository.findById(id);
        if (existing.isPresent()) {
            Produit p = existing.get();
            p.setNom(produit.getNom());
            p.setDescription(produit.getDescription());
            p.setPrix(produit.getPrix());
            p.setQuantiteStock(produit.getQuantiteStock());
            Produit updated = produitRepository.save(p);
            logger.info("Produit {} modifié avec succès", id);
            return updated;
        }
        logger.warn("Produit {} non trouvé pour modification", id);
        return null;
    }

    public void supprimerProduit(Long id) {
        logger.info("Suppression du produit ID: {}", id);
        produitRepository.deleteById(id);
        logger.info("Produit {} supprimé", id);
    }

    public List<Produit> listerProduits() {
        logger.info("Récupération de la liste des produits");
        return produitRepository.findAll();
    }

    public Optional<Produit> consulterProduit(Long id) {
        logger.info("Consultation du produit ID: {}", id);
        return produitRepository.findById(id);
    }
}