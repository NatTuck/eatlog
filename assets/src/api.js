const API_BASE = '/api/v1';

export const apiRequest = async (endpoint, options = {}) => {
  const session = localStorage.getItem('session');
  const headers = { 'Content-Type': 'application/json', ...options.headers };

  if (session) {
    const data = JSON.parse(session);
    const expires = new Date(data.expires);
    if (expires <= new Date()) {
      localStorage.removeItem('session');
      window.location.href = '/';
      throw new Error('Token expired');
    }
    headers.Authorization = `Bearer ${data.token}`;
  }

  const response = await fetch(`${API_BASE}${endpoint}`, { ...options, headers });

  if (response.status === 401) {
    const errorData = await response.json();
    if (errorData.error === 'invalid_token') {
      localStorage.removeItem('session');
      window.location.href = '/';
      throw new Error('Invalid token');
    }
  }

  return response;
};