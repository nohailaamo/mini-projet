package amouhal.nouhayla.commande.dto;

import java.util.List;

public class CreateCommandeRequest {
    private List<LigneCommandeDto> lignes;

    public CreateCommandeRequest() {}

    public CreateCommandeRequest(List<LigneCommandeDto> lignes) {
        this.lignes = lignes;
    }

    public List<LigneCommandeDto> getLignes() {
        return lignes;
    }

    public void setLignes(List<LigneCommandeDto> lignes) {
        this.lignes = lignes;
    }

    public static class LigneCommandeDto {
        private Long produitId;
        private Integer quantite;
        private Double prix;

        public LigneCommandeDto() {}

        public LigneCommandeDto(Long produitId, Integer quantite, Double prix) {
            this.produitId = produitId;
            this.quantite = quantite;
            this.prix = prix;
        }

        public Long getProduitId() {
            return produitId;
        }

        public void setProduitId(Long produitId) {
            this.produitId = produitId;
        }

        public Integer getQuantite() {
            return quantite;
        }

        public void setQuantite(Integer quantite) {
            this.quantite = quantite;
        }

        public Double getPrix() {
            return prix;
        }

        public void setPrix(Double prix) {
            this.prix = prix;
        }
    }
}

