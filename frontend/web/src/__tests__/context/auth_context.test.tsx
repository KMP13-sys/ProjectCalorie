import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { AuthProvider, useAuth } from '../../context/auth_context';
import { authAPI } from '../../services/auth_service';

jest.mock('../../services/auth_service');

const mockedAuthAPI = authAPI as jest.Mocked<typeof authAPI>;

// Test component to access useAuth hook
const TestComponent = () => {
  const { user, isAuthenticated, isLoading, role } = useAuth();
  
  if (isLoading) return <div>Loading...</div>;
  
  return (
    <div>
      <div data-testid="authenticated">{isAuthenticated ? 'true' : 'false'}</div>
      <div data-testid="role">{role || 'none'}</div>
      <div data-testid="username">{user?.username || 'no-user'}</div>
    </div>
  );
};

describe('AuthContext', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    localStorage.clear();
  });

  it('should provide initial unauthenticated state', async () => {
    mockedAuthAPI.getCurrentUser.mockReturnValue(null);

    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    );

    await waitFor(() => {
      expect(screen.getByTestId('authenticated')).toHaveTextContent('false');
      expect(screen.getByTestId('role')).toHaveTextContent('none');
      expect(screen.getByTestId('username')).toHaveTextContent('no-user');
    });
  });

  it('should provide authenticated state when user exists', async () => {
    const mockUser = {
      user_id: 1,
      username: 'testuser',
      email: 'test@example.com',
      role: 'user' as const,
    };

    localStorage.setItem('accessToken', 'test-token');
    mockedAuthAPI.getCurrentUser.mockReturnValue(mockUser);

    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    );

    await waitFor(() => {
      expect(screen.getByTestId('authenticated')).toHaveTextContent('true');
      expect(screen.getByTestId('role')).toHaveTextContent('user');
      expect(screen.getByTestId('username')).toHaveTextContent('testuser');
    });
  });

  it('should throw error when useAuth is used outside provider', () => {
    // Suppress console.error for this test
    const consoleError = jest.spyOn(console, 'error').mockImplementation(() => {});

    expect(() => {
      render(<TestComponent />);
    }).toThrow('useAuth must be used within an AuthProvider');

    consoleError.mockRestore();
  });
});
