import axios from 'axios';

const API_BASE_URL = 'http://localhost:8888';

// Store the token in a module variable (works for SPA, ensure reload updates it)
let jwtToken: string | null = null;

const api = axios.create({
  baseURL: API_BASE_URL,
});

// Use a request interceptor to always add Authorization if the token exists
api.interceptors.request.use(
    (config) => {
      if (jwtToken) {
        config.headers = config.headers || {};
        config.headers['Authorization'] = `Bearer ${jwtToken}`;
      }
      return config;
    },
    (error) => Promise.reject(error)
);

/**
 * Set the JWT token for all outgoing requests
 * Call this after login or token refresh
 */
export const setAuthToken = (token: string | null) => {
  jwtToken = token;
};

// Product APIs
export const productAPI = {
  getAll: () => api.get('/api/produits'),
  getById: (id: number) => api.get(`/api/produits/${id}`),
  create: (product: any) => api.post('/api/produits', product),
  update: (id: number, product: any) => api.put(`/api/produits/${id}`, product),
  delete: (id: number) => api.delete(`/api/produits/${id}`),
};

// Order APIs
export const orderAPI = {
  getMyOrders: () => api.get('/api/commandes'),
  getAllOrders: () => api.get('/api/commandes/all'),
  getById: (id: number) => api.get(`/api/commandes/${id}`),
  create: (order: any) => api.post('/api/commandes', order),
};

export default api;