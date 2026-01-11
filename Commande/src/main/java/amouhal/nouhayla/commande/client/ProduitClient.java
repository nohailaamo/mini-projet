package amouhal.nouhayla.commande.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "produit-service", url = "${produit.service.url}")
public interface ProduitClient {
    
    @GetMapping("/api/produits/{id}")
    ProduitDto getProduit(@PathVariable("id") Long id);
}
