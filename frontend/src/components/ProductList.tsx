import React, { useEffect, useState } from 'react';
import { useKeycloak } from '@react-keycloak/web';
import { productAPI } from '../services/api';
import './ProductList.css';

interface Product {
  id: number;
  nom: string;
  description: string;
  prix: number;
  quantiteStock: number;
}

const ProductList: React.FC = () => {
  const { keycloak } = useKeycloak();
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);
  const [formData, setFormData] = useState({
    nom: '',
    description: '',
    prix: 0,
    quantiteStock: 0
  });

  const isAdmin = keycloak?.hasRealmRole('ADMIN');

  useEffect(() => {
    if (keycloak?.authenticated) {
      loadProducts();
    }
  }, [keycloak?.authenticated]);

  const loadProducts = async () => {
    try {
      setLoading(true);
      console.log('Chargement des produits...');
      const response = await productAPI.getAll();
      console.log('Produits reçus:', response.data);
      setProducts(response.data);
      setError(null);
    } catch (err: any) {
      console.error('Erreur complète:', {
        status: err.response?.status,
        message: err.message,
        data: err.response?.data,
      });
      if (err.response?.status === 401 || err.response?.status === 403) {
        setError('Accès non autorisé. Veuillez vous connecter.');
      } else {
        setError(`Erreur lors du chargement des produits: ${err.message}`);
      }
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingProduct) {
        await productAPI.update(editingProduct.id, formData);
      } else {
        await productAPI.create(formData);
      }
      setShowAddForm(false);
      setEditingProduct(null);
      setFormData({ nom: '', description: '', prix: 0, quantiteStock: 0 });
      loadProducts();
    } catch (err) {
      console.error('Error saving product:', err);
      setError('Erreur lors de l\'enregistrement du produit');
    }
  };

  const handleEdit = (product: Product) => {
    setEditingProduct(product);
    setFormData({
      nom: product.nom,
      description: product.description,
      prix: product.prix,
      quantiteStock: product.quantiteStock
    });
    setShowAddForm(true);
  };

  const handleDelete = async (id: number) => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer ce produit ?')) {
      try {
        await productAPI.delete(id);
        loadProducts();
      } catch (err) {
        console.error('Error deleting product:', err);
        setError('Erreur lors de la suppression du produit');
      }
    }
  };

  if (loading) return <div className="loading">Chargement...</div>;
  if (error) return <div className="error">{error}</div>;

  return (
    <div className="product-list">
      <div className="header">
        <h2>Catalogue de Produits</h2>
        {isAdmin && !showAddForm && (
          <button className="btn-primary" onClick={() => setShowAddForm(true)}>
            Ajouter un produit
          </button>
        )}
      </div>

      {showAddForm && isAdmin && (
        <div className="product-form">
          <h3>{editingProduct ? 'Modifier le produit' : 'Nouveau produit'}</h3>
          <form onSubmit={handleSubmit}>
            <input
              type="text"
              placeholder="Nom"
              value={formData.nom}
              onChange={(e) => setFormData({ ...formData, nom: e.target.value })}
              required
            />
            <textarea
              placeholder="Description"
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              required
            />
            <input
              type="number"
              placeholder="Prix"
              value={formData.prix}
              onChange={(e) => setFormData({ ...formData, prix: parseFloat(e.target.value) })}
              step="0.01"
              required
            />
            <input
              type="number"
              placeholder="Quantité en stock"
              value={formData.quantiteStock}
              onChange={(e) => setFormData({ ...formData, quantiteStock: parseInt(e.target.value) })}
              required
            />
            <div className="form-actions">
              <button type="submit" className="btn-primary">
                {editingProduct ? 'Mettre à jour' : 'Ajouter'}
              </button>
              <button
                type="button"
                className="btn-secondary"
                onClick={() => {
                  setShowAddForm(false);
                  setEditingProduct(null);
                  setFormData({ nom: '', description: '', prix: 0, quantiteStock: 0 });
                }}
              >
                Annuler
              </button>
            </div>
          </form>
        </div>
      )}

      <div className="products-grid">
        {products.map((product) => (
          <div key={product.id} className="product-card">
            <h3>{product.nom}</h3>
            <p className="description">{product.description}</p>
            <p className="price">{product.prix.toFixed(2)} €</p>
            <p className="stock">Stock: {product.quantiteStock}</p>
            {isAdmin && (
              <div className="card-actions">
                <button className="btn-edit" onClick={() => handleEdit(product)}>
                  Modifier
                </button>
                <button className="btn-delete" onClick={() => handleDelete(product.id)}>
                  Supprimer
                </button>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};

export default ProductList;
