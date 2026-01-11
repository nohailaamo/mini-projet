package amouhal.nouhayla.produit.repository;
import amouhal.nouhayla.produit.entity.Produit;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProduitRepository extends JpaRepository<Produit, Long> {}