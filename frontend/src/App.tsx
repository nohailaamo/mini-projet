import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Link, Navigate } from 'react-router-dom';
import { ReactKeycloakProvider, useKeycloak } from '@react-keycloak/web';
import keycloak from './keycloak';
import { setAuthToken } from './services/api';
import ProductList from './components/ProductList';
import OrderList from './components/OrderList';
import './App.css';

const PrivateRoute: React.FC<{ children: React.ReactElement }> = ({ children }) => {
  const { keycloak } = useKeycloak();
  
  if (!keycloak?.authenticated) {
    return <div className="loading">Authentification en cours...</div>;
  }
  
  return children;
};

const Navigation: React.FC = () => {
  const { keycloak } = useKeycloak();
  
  const handleLogout = () => {
    keycloak?.logout();
  };

  if (!keycloak?.authenticated) {
    return null;
  }

  const username = keycloak?.tokenParsed?.preferred_username || 'Utilisateur';
  const isAdmin = keycloak?.hasRealmRole('ADMIN');
  const isClient = keycloak?.hasRealmRole('CLIENT');

  return (
    <nav className="navbar">
      <div className="nav-brand">
        <h1>Microservices App</h1>
      </div>
      <div className="nav-links">
        <Link to="/products">Produits</Link>
        {isClient && <Link to="/orders">Commandes</Link>}
        {isAdmin && <Link to="/orders">Toutes les Commandes</Link>}
      </div>
      <div className="nav-user">
        <span className="username">
          {username} ({isAdmin ? 'ADMIN' : 'CLIENT'})
        </span>
        <button onClick={handleLogout} className="btn-logout">
          Déconnexion
        </button>
      </div>
    </nav>
  );
};

const AppContent: React.FC = () => {
  const { keycloak, initialized } = useKeycloak();

  useEffect(() => {
    if (keycloak?.token) {
      setAuthToken(keycloak.token);
    }
  }, [keycloak?.token]);

  if (!initialized) {
    return <div className="loading">Initialisation...</div>;
  }

  if (!keycloak?.authenticated) {
    return (
      <div className="login-page">
        <div className="login-container">
          <h1>Bienvenue</h1>
          <p>Application de gestion de produits et commandes</p>
          <button className="btn-login" onClick={() => keycloak?.login()}>
            Se connecter
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="App">
      <Navigation />
      <main className="main-content">
        <Routes>
          <Route path="/" element={<Navigate to="/products" replace />} />
          <Route
            path="/products"
            element={
              <PrivateRoute>
                <ProductList />
              </PrivateRoute>
            }
          />
          <Route
            path="/orders"
            element={
              <PrivateRoute>
                <OrderList />
              </PrivateRoute>
            }
          />
        </Routes>
      </main>
    </div>
  );
};

function App() {
  return (
    <ReactKeycloakProvider
      authClient={keycloak}
      initOptions={{
        onLoad: 'check-sso',
        checkLoginIframe: false,
      }}
    >
      <Router>
        <AppContent />
      </Router>
    </ReactKeycloakProvider>
  );
}

export default App;
