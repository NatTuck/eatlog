import { create } from 'zustand';

const useAuthStore = create((set, get) => ({
  session: null,
  isAuthenticated: () => {
    const session = get().session;
    return session && new Date(session.expires) > new Date();
  },
  initSession: () => {
    const stored = localStorage.getItem('session');
    if (stored) {
      const session = JSON.parse(stored);
      set({ session });
    }
  },
  setSession: (data) => {
    if (data) {
      localStorage.setItem('session', JSON.stringify(data));
      set({ session: data });
    } else {
      localStorage.removeItem('session');
      set({ session: null });
    }
  },
  logout: () => {
    get().setSession(null);
  },
  checkExpiry: () => {
    if (!get().isAuthenticated()) {
      get().logout();
    }
  },
}));

// Init on store creation
useAuthStore.getState().initSession();

export default useAuthStore;