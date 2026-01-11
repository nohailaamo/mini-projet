import axios from 'axios';

const API_BASE_URL = 'http://localhost:8888';

const api = axios.create({
  baseURL: API_BASE_URL,
});

// Add request interceptor to include JWT token
export const setAuthToken = (token: string | null) => {
  if (token) {
    api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  } else {
    delete api.defaults.headers.common['Authorization'];
  }
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
