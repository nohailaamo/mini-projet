package amouhal.nouhayla.produit.config;

import amouhal.nouhayla.produit.entity.Produit;
import amouhal.nouhayla.produit.repository.ProduitRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);

    @Autowired
    private ProduitRepository produitRepository;

    @Override
    public void run(String... args) throws Exception {
        // Only initialize if database is empty
        if (produitRepository.count() == 0) {
            logger.info("Initializing database with sample products...");

            Produit p1 = new Produit();
            p1.setNom("Laptop Dell XPS 15");
            p1.setDescription("Ordinateur portable haute performance avec écran 15 pouces 4K");
            p1.setPrix(1499.99);
            p1.setQuantiteStock(10);
            produitRepository.save(p1);

            Produit p2 = new Produit();
            p2.setNom("iPhone 15 Pro");
            p2.setDescription("Smartphone Apple dernière génération avec puce A17 Pro");
            p2.setPrix(1199.99);
            p2.setQuantiteStock(25);
            produitRepository.save(p2);

            Produit p3 = new Produit();
            p3.setNom("Samsung Galaxy S24");
            p3.setDescription("Smartphone Android flagship avec appareil photo 200MP");
            p3.setPrix(999.99);
            p3.setQuantiteStock(15);
            produitRepository.save(p3);

            Produit p4 = new Produit();
            p4.setNom("iPad Pro 12.9\"");
            p4.setDescription("Tablette Apple avec puce M2 et écran Liquid Retina");
            p4.setPrix(1299.99);
            p4.setQuantiteStock(8);
            produitRepository.save(p4);

            Produit p5 = new Produit();
            p5.setNom("Sony WH-1000XM5");
            p5.setDescription("Casque sans fil avec réduction de bruit active de pointe");
            p5.setPrix(399.99);
            p5.setQuantiteStock(30);
            produitRepository.save(p5);

            Produit p6 = new Produit();
            p6.setNom("Logitech MX Master 3S");
            p6.setDescription("Souris sans fil ergonomique pour professionnels");
            p6.setPrix(99.99);
            p6.setQuantiteStock(50);
            produitRepository.save(p6);

            Produit p7 = new Produit();
            p7.setNom("Keychron K8 Pro");
            p7.setDescription("Clavier mécanique sans fil programmable");
            p7.setPrix(129.99);
            p7.setQuantiteStock(20);
            produitRepository.save(p7);

            Produit p8 = new Produit();
            p8.setNom("LG UltraWide 34\"");
            p8.setDescription("Écran ultra-large incurvé 21:9 QHD");
            p8.setPrix(599.99);
            p8.setQuantiteStock(12);
            produitRepository.save(p8);

            logger.info("Database initialized with {} products", produitRepository.count());
        } else {
            logger.info("Database already contains {} products, skipping initialization", produitRepository.count());
        }
    }
}
