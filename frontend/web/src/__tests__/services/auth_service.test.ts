// Mock axios module
jest.mock('axios', () => {
  const mockAxiosInstance = {
    get: jest.fn(),
    post: jest.fn(),
    put: jest.fn(),
    delete: jest.fn(),
    interceptors: {
      request: { use: jest.fn(), eject: jest.fn(), clear: jest.fn() },
      response: { use: jest.fn(), eject: jest.fn(), clear: jest.fn() },
    },
  };
  
  return {
    __esModule: true,
    default: {
      create: jest.fn(() => mockAxiosInstance),
    },
  };
});

// Now import the service after mocking
import { authAPI, LoginResponse, RegisterResponse, User } from '../../services/auth_service';
import axios from 'axios';

// Get the mocked axios instance for testing
const mockAxiosInstance = (axios.create as jest.Mock)();

describe('Auth Service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    localStorage.clear();
  });

  describe('login', () => {
    it('should login successfully and store token', async () => {
      const mockResponse: LoginResponse = {
        message: 'Login successful',
        role: 'user',
        userId: 1,
        accessToken: 'test-token',
        expiresIn: '24h',
      };

      mockAxiosInstance.post.mockResolvedValueOnce({ data: mockResponse });

      const result = await authAPI.login('testuser', 'password123');

      expect(result).toEqual(mockResponse);
      expect(localStorage.getItem('accessToken')).toBe('test-token');
      expect(localStorage.getItem('user')).toBeTruthy();
      expect(mockAxiosInstance.post).toHaveBeenCalledWith('/api/auth/login', {
        username: 'testuser',
        password: 'password123',
        platform: 'web',
      });
    });

    it('should handle login errors', async () => {
      const errorMessage = 'Invalid credentials';
      mockAxiosInstance.post.mockRejectedValueOnce({
        response: { data: { message: errorMessage } },
      });

      await expect(authAPI.login('wrong', 'credentials')).rejects.toThrow(errorMessage);
      expect(localStorage.getItem('accessToken')).toBeNull();
    });

    it('should handle network errors', async () => {
      mockAxiosInstance.post.mockRejectedValueOnce(new Error('Network error'));

      await expect(authAPI.login('user', 'pass')).rejects.toThrow('เกิดข้อผิดพลาดในการเข้าสู่ระบบ');
    });
  });

  describe('register', () => {
    it('should register successfully', async () => {
      const mockResponse: RegisterResponse = {
        message: 'User registered successfully',
      };

      const registerData = {
        username: 'newuser',
        email: 'new@example.com',
        phone_number: '1234567890',
        password: 'Password@123',
        age: 25,
        gender: 'male',
        height: 175,
        weight: 70,
        goal: 'maintain weight',
      };

      mockAxiosInstance.post.mockResolvedValueOnce({ data: mockResponse });

      const result = await authAPI.register(registerData);

      expect(result).toEqual(mockResponse);
      expect(mockAxiosInstance.post).toHaveBeenCalledWith('/api/auth/register', registerData);
    });

    it('should handle registration errors', async () => {
      const registerData = {
        username: 'existinguser',
        email: 'existing@example.com',
        phone_number: '1234567890',
        password: 'Password@123',
        age: 25,
        gender: 'male',
        height: 175,
        weight: 70,
        goal: 'maintain weight',
      };

      const error: any = new Error('Request failed');
      error.response = { data: { message: 'Username already exists' } };
      mockAxiosInstance.post.mockRejectedValueOnce(error);

      await expect(authAPI.register(registerData)).rejects.toThrow();
    });
  });

  describe('logout', () => {
    it('should clear localStorage on logout', () => {
      localStorage.setItem('accessToken', 'test-token');
      localStorage.setItem('user', JSON.stringify({ user_id: 1, username: 'test' }));

      // authAPI.logout() also redirects to /login, but we can't easily test that in jsdom
      // Just verify localStorage is cleared
      authAPI.logout();

      expect(localStorage.getItem('accessToken')).toBeNull();
      expect(localStorage.getItem('user')).toBeNull();
    });
  });

  describe('getCurrentUser', () => {
    it('should return user from localStorage', () => {
      const mockUser: User = {
        user_id: 1,
        username: 'testuser',
        email: 'test@example.com',
        role: 'user',
      };

      localStorage.setItem('user', JSON.stringify(mockUser));

      const user = authAPI.getCurrentUser();

      expect(user).toEqual(mockUser);
    });

    it('should return null if no user in localStorage', () => {
      const user = authAPI.getCurrentUser();
      expect(user).toBeNull();
    });

    it('should return null if user data is invalid JSON', () => {
      localStorage.setItem('user', 'invalid-json');
      const user = authAPI.getCurrentUser();
      expect(user).toBeNull();
    });
  });

  describe('isAuthenticated', () => {
    it('should return true if token exists', () => {
      localStorage.setItem('accessToken', 'test-token');
      expect(authAPI.isAuthenticated()).toBe(true);
    });

    it('should return false if no token', () => {
      expect(authAPI.isAuthenticated()).toBe(false);
    });
  });

  describe('getToken', () => {
    it('should return token from localStorage', () => {
      localStorage.setItem('accessToken', 'test-token');
      expect(authAPI.getToken()).toBe('test-token');
    });

    it('should return null if no token', () => {
      expect(authAPI.getToken()).toBeNull();
    });
  });

  describe('deleteAccount', () => {
    it('should delete account and clear storage', async () => {
      localStorage.setItem('accessToken', 'test-token');
      localStorage.setItem('user', JSON.stringify({ user_id: 1 }));

      mockAxiosInstance.delete.mockResolvedValueOnce({});

      await authAPI.deleteAccount();

      expect(mockAxiosInstance.delete).toHaveBeenCalledWith('/api/auth/delete-account');
      expect(localStorage.getItem('accessToken')).toBeNull();
      expect(localStorage.getItem('user')).toBeNull();
    });
  });

  describe('fetchCurrentUser', () => {
    it('should fetch and update user data', async () => {
      const mockUser: User = {
        user_id: 1,
        username: 'testuser',
        email: 'test@example.com',
        role: 'user',
        age: 25,
        gender: 'male',
        height: 175,
        weight: 70,
      };

      localStorage.setItem('user', JSON.stringify({ user_id: 1, username: 'test', email: '', role: 'user' }));

      mockAxiosInstance.get.mockResolvedValueOnce({ data: mockUser });

      const result = await authAPI.fetchCurrentUser();

      expect(result).toEqual(mockUser);
      expect(mockAxiosInstance.get).toHaveBeenCalledWith('/api/profile/1');
      expect(JSON.parse(localStorage.getItem('user') || '{}')).toEqual(mockUser);
    });

    it('should return null if no current user', async () => {
      const result = await authAPI.fetchCurrentUser();
      expect(result).toBeNull();
    });

    it('should handle fetch errors', async () => {
      localStorage.setItem('user', JSON.stringify({ user_id: 1, username: 'test', email: '', role: 'user' }));
      mockAxiosInstance.get.mockRejectedValueOnce(new Error('Network error'));

      const result = await authAPI.fetchCurrentUser();
      expect(result).toBeNull();
    });
  });

  describe('getAllUsers', () => {
    it('should fetch all users for admin', async () => {
      const mockUsers: User[] = [
        { user_id: 1, username: 'user1', email: 'user1@example.com', role: 'user' },
        { user_id: 2, username: 'user2', email: 'user2@example.com', role: 'user' },
      ];

      mockAxiosInstance.get.mockResolvedValueOnce({
        data: { message: 'Success', users: mockUsers },
      });

      const result = await authAPI.getAllUsers();

      expect(result).toEqual(mockUsers);
      expect(mockAxiosInstance.get).toHaveBeenCalledWith('/api/admin/users');
    });

    it('should handle errors when fetching users', async () => {
      mockAxiosInstance.get.mockRejectedValueOnce({
        response: { data: { message: 'Unauthorized' } },
      });

      await expect(authAPI.getAllUsers()).rejects.toThrow('Unauthorized');
    });
  });
});
