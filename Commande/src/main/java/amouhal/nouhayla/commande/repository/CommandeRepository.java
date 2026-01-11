package amouhal.nouhayla.commande.repository;
import amouhal.nouhayla.commande.entity.Commande;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CommandeRepository extends JpaRepository<Commande, Long> {
    List<Commande> findByClientUsername(String username);
}