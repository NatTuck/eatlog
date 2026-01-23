import { Link, Outlet } from 'react-router-dom';
import useAuthStore from '../store/auth';

function Layout() {
  const { session, logout, isAuthenticated } = useAuthStore();

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div>
              {isAuthenticated() ? (
                <span className="text-gray-900">
                  {session.login} |{' '}
                  <button
                    onClick={logout}
                    className="text-indigo-600 hover:text-indigo-900 font-medium"
                  >
                    Log Out
                  </button>
                </span>
              ) : (
                <Link
                  to="/login"
                  className="text-indigo-600 hover:text-indigo-900 font-medium"
                >
                  Log in
                </Link>
              )}
            </div>
          </div>
        </div>
      </header>
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <Outlet />
      </main>
    </div>
  );
}

export default Layout;