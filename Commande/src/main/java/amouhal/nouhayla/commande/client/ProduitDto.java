package amouhal.nouhayla.commande.client;

import lombok.Data;

@Data
public class ProduitDto {
    private Long id;
    private String nom;
    private String description;
    private Double prix;
    private Integer quantiteStock;
}
