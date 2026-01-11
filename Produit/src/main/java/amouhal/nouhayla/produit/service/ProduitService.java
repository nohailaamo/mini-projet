package amouhal.nouhayla.produit.service;
import amouhal.nouhayla.produit.entity.Produit;
import amouhal.nouhayla.produit.repository.ProduitRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProduitService {

    @Autowired
    private ProduitRepository produitRepository;

    public Produit ajouterProduit(Produit produit) {
        return produitRepository.save(produit);
    }

    public Produit modifierProduit(Long id, Produit produit) {
        Optional<Produit> existing = produitRepository.findById(id);
        if (existing.isPresent()) {
            Produit p = existing.get();
            p.setNom(produit.getNom());
            p.setDescription(produit.getDescription());
            p.setPrix(produit.getPrix());
            p.setQuantiteStock(produit.getQuantiteStock());
            return produitRepository.save(p);
        }
        return null;
    }

    public void supprimerProduit(Long id) {
        produitRepository.deleteById(id);
    }

    public List<Produit> listerProduits() {
        return produitRepository.findAll();
    }

    public Optional<Produit> consulterProduit(Long id) {
        return produitRepository.findById(id);
    }
}