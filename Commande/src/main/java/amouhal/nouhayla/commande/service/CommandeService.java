package amouhal.nouhayla.commande.service;
import amouhal.nouhayla.commande.entity.Commande;
import amouhal.nouhayla.commande.entity.LigneCommande;
import amouhal.nouhayla.commande.repository.CommandeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class CommandeService {

    @Autowired
    private CommandeRepository commandeRepository;

    // Création
    public Commande createCommande(Commande commande) {
        commande.setDateCommande(LocalDateTime.now());
        double total = 0;
        if (commande.getLignes() != null) {
            for (LigneCommande ligne : commande.getLignes()) {
                ligne.setCommande(commande);
                total += (ligne.getPrix() * ligne.getQuantite());
            }
        }
        commande.setMontantTotal(total);
        commande.setStatut("EN_COURS");
        return commandeRepository.save(commande);
    }

    public List<Commande> getCommandesByClient(String username) {
        return commandeRepository.findByClientUsername(username);
    }

    public Optional<Commande> getCommande(Long id) {
        return commandeRepository.findById(id);
    }

    public List<Commande> getAllCommandes() {
        return commandeRepository.findAll();
    }
}