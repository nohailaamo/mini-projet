import React, { useEffect, useState } from 'react';
import { useKeycloak } from '@react-keycloak/web';
import { orderAPI, productAPI } from '../services/api';
import './OrderList.css';

interface Product {
  id: number;
  nom: string;
  prix: number;
  quantiteStock: number;
}

interface OrderLine {
  produitId: number;
  quantite: number;
  prix: number;
}

interface Order {
  id: number;
  dateCommande: string;
  statut: string;
  montantTotal: number;
  clientUsername: string;
  lignes: OrderLine[];
}

const OrderList: React.FC = () => {
  const { keycloak } = useKeycloak();
  const [orders, setOrders] = useState<Order[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [orderLines, setOrderLines] = useState<{ productId: number; quantity: number }[]>([
    { productId: 0, quantity: 1 }
  ]);

  const isAdmin = keycloak?.hasRealmRole('ADMIN');

  useEffect(() => {
    if (keycloak?.authenticated) {
      loadOrders();
      loadProducts();
    }
  }, [keycloak?.authenticated, isAdmin]);

  const loadOrders = async () => {
    try {
      setLoading(true);
      console.log('Chargement des commandes... isAdmin:', isAdmin);
      const response = isAdmin ? await orderAPI.getAllOrders() : await orderAPI.getMyOrders();
      console.log('Commandes reçues:', response.data);
      setOrders(response.data);
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
        setError(`Erreur lors du chargement des commandes: ${err.message}`);
      }
    } finally {
      setLoading(false);
    }
  };

  const loadProducts = async () => {
    try {
      console.log('Chargement des produits...');
      const response = await productAPI.getAll();
      console.log('Produits reçus:', response.data);
      setProducts(response.data);
    } catch (err: any) {
      console.error('Erreur produits:', {
        status: err.response?.status,
        message: err.message,
        data: err.response?.data,
      });
    }
  };

  const handleAddOrderLine = () => {
    setOrderLines([...orderLines, { productId: 0, quantity: 1 }]);
  };

  const handleRemoveOrderLine = (index: number) => {
    setOrderLines(orderLines.filter((_, i) => i !== index));
  };

  const handleOrderLineChange = (index: number, field: 'productId' | 'quantity', value: number) => {
    const newOrderLines = [...orderLines];
    newOrderLines[index][field] = value;
    setOrderLines(newOrderLines);
  };

  const handleSubmitOrder = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      console.log('Création de commande avec lignes:', orderLines);

      // Créer l'objet commande avec les lignes
      const commande = {
        lignes: orderLines.map(line => {
          const product = products.find(p => p.id === line.productId);
          return {
            produitId: line.productId,
            quantite: line.quantity,
            prix: product?.prix || 0
          };
        })
      };

      console.log('Payload envoyé:', commande);

      await orderAPI.create(commande);
      console.log('Commande créée avec succès');
      setShowCreateForm(false);
      setOrderLines([{ productId: 0, quantity: 1 }]);
      loadOrders();
    } catch (err: any) {
      console.error('Erreur complète:', {
        status: err.response?.status,
        message: err.message,
        data: err.response?.data,
      });
      if (err.response?.data) {
        setError(err.response.data.message || 'Erreur lors de la création de la commande');
      } else {
        setError('Erreur lors de la création de la commande');
      }
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('fr-FR');
  };

  if (loading) return <div className="loading">Chargement...</div>;

  return (
    <div className="order-list">
      <div className="header">
        <h2>{isAdmin ? 'Toutes les Commandes' : 'Mes Commandes'}</h2>
        {!isAdmin && !showCreateForm && (
          <button className="btn-primary" onClick={() => setShowCreateForm(true)}>
            Créer une commande
          </button>
        )}
      </div>

      {error && <div className="error">{error}</div>}

      {showCreateForm && !isAdmin && (
        <div className="order-form">
          <h3>Nouvelle Commande</h3>
          <form onSubmit={handleSubmitOrder}>
            {orderLines.map((line, index) => (
              <div key={index} className="order-line">
                <select
                  value={line.productId}
                  onChange={(e) => handleOrderLineChange(index, 'productId', parseInt(e.target.value))}
                  required
                >
                  <option value={0}>Sélectionner un produit</option>
                  {products.map(product => (
                    <option key={product.id} value={product.id}>
                      {product.nom} - {product.prix.toFixed(2)}€ (Stock: {product.quantiteStock})
                    </option>
                  ))}
                </select>
                <input
                  type="number"
                  min="1"
                  value={line.quantity}
                  onChange={(e) => handleOrderLineChange(index, 'quantity', parseInt(e.target.value))}
                  placeholder="Quantité"
                  required
                />
                {orderLines.length > 1 && (
                  <button
                    type="button"
                    className="btn-delete-small"
                    onClick={() => handleRemoveOrderLine(index)}
                  >
                    ✕
                  </button>
                )}
              </div>
            ))}
            <button type="button" className="btn-add-line" onClick={handleAddOrderLine}>
              + Ajouter un produit
            </button>
            <div className="form-actions">
              <button type="submit" className="btn-primary">Commander</button>
              <button
                type="button"
                className="btn-secondary"
                onClick={() => {
                  setShowCreateForm(false);
                  setOrderLines([{ productId: 0, quantity: 1 }]);
                  setError(null);
                }}
              >
                Annuler
              </button>
            </div>
          </form>
        </div>
      )}

      <div className="orders-grid">
        {orders.length === 0 ? (
          <p>Aucune commande trouvée</p>
        ) : (
          orders.map((order) => (
            <div key={order.id} className="order-card">
              <div className="order-header">
                <h3>Commande #{order.id}</h3>
                <span className={`status status-${order.statut.toLowerCase()}`}>
                  {order.statut}
                </span>
              </div>
              <p className="order-date">{formatDate(order.dateCommande)}</p>
              {isAdmin && <p className="client">Client: {order.clientUsername}</p>}
              <div className="order-lines">
                <h4>Produits:</h4>
                {order.lignes?.map((ligne, idx) => (
                  <div key={idx} className="line-item">
                    <span>Produit ID: {ligne.produitId}</span>
                    <span>Quantité: {ligne.quantite}</span>
                    <span>{(ligne.prix * ligne.quantite).toFixed(2)}€</span>
                  </div>
                ))}
              </div>
              <p className="total">Total: {order.montantTotal.toFixed(2)} €</p>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default OrderList;
