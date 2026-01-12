import axios from 'axios';

// URLs directes des microservices
const PRODUCT_API_BASE_URL = 'http://localhost:8081';
const ORDER_API_BASE_URL = 'http://localhost:8082';

// Stockage du token JWT
let jwtToken: string | null = null;

// Instances axios séparées pour chaque microservice
const productApi = axios.create({
    baseURL: PRODUCT_API_BASE_URL,
});

const orderApi = axios.create({
    baseURL: ORDER_API_BASE_URL,
});

// Ajoute le JWT à chaque requête pour Produits
productApi.interceptors.request.use(
    (config) => {
        if (jwtToken) {
            config.headers = config.headers || {};
            config.headers['Authorization'] = `Bearer ${jwtToken}`;
        }
        return config;
    },
    (error) => Promise.reject(error)
);

// Ajoute le JWT à chaque requête pour Commandes
orderApi.interceptors.request.use(
    (config) => {
        if (jwtToken) {
            config.headers = config.headers || {};
            config.headers['Authorization'] = `Bearer ${jwtToken}`;
        }
        return config;
    },
    (error) => Promise.reject(error)
);

// Intercepteur de réponse pour logs d'erreur
productApi.interceptors.response.use(
    (response) => response,
    (error) => {
        console.error('Product API Error:', error.response?.status, error.response?.data);
        return Promise.reject(error);
    }
);

orderApi.interceptors.response.use(
    (response) => response,
    (error) => {
        console.error('Order API Error:', error.response?.status, error.response?.data);
        return Promise.reject(error);
    }
);

// Fonction pour mettre à jour le token
export const setAuthToken = (token: string | null) => {
    jwtToken = token;
};

// Product APIs
export const productAPI = {
    getAll: () => productApi.get('/api/produits'),
    getById: (id: number) => productApi.get(`/api/produits/${id}`),
    create: (product: any) => productApi.post('/api/produits', product),
    update: (id: number, product: any) => productApi.put(`/api/produits/${id}`, product),
    delete: (id: number) => productApi.delete(`/api/produits/${id}`),
};

// Order APIs
export const orderAPI = {
    getMyOrders: () => orderApi.get('/api/commandes'),
    getAllOrders: () => orderApi.get('/api/commandes/all'),
    getById: (id: number) => orderApi.get(`/api/commandes/${id}`),
    create: (order: any) => orderApi.post('/api/commandes', order),
};

export default {
    productAPI,
    orderAPI,
    setAuthToken,
};