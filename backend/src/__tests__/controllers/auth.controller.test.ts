import { Request, Response } from 'express';
import { register, registerAdmin, login, refreshToken, logout, deleteOwnAccount } from '../../controllers/auth.controller';
import db from '../../config/db';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

// Mock dependencies
jest.mock('../../config/db');
jest.mock('bcrypt');
jest.mock('jsonwebtoken');

describe('Auth Controller', () => {
  let mockRequest: Partial<Request>;
  let mockResponse: Partial<Response>;
  let jsonMock: jest.Mock;
  let statusMock: jest.Mock;

  beforeEach(() => {
    jsonMock = jest.fn();
    statusMock = jest.fn().mockReturnValue({ json: jsonMock });
    
    mockRequest = {
      body: {},
      params: {},
    };
    
    mockResponse = {
      status: statusMock,
      json: jsonMock,
    };

    jest.clearAllMocks();
  });

  describe('register', () => {
    it('should register a new user successfully', async () => {
      mockRequest.body = {
        username: 'testuser',
        email: 'test@example.com',
        phone_number: '1234567890',
        password: 'Password@123',
        age: 25,
        gender: 'male',
        height: 175,
        weight: 70,
        goal: 'maintain weight',
      };

      (db.query as jest.Mock)
        .mockResolvedValueOnce([[]])  // No existing user
        .mockResolvedValueOnce([{ insertId: 1 }]); // Insert success
      
      (bcrypt.hash as jest.Mock).mockResolvedValue('hashedPassword');

      await register(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(201);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'User registered successfully' });
    });

    it('should reject invalid username', async () => {
      mockRequest.body = {
        username: '12',  // Too short
        email: 'test@example.com',
        phone_number: '1234567890',
        password: 'Password@123',
        age: 25,
      };

      await register(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(400);
      expect(jsonMock).toHaveBeenCalledWith(
        expect.objectContaining({ message: expect.stringContaining('Username') })
      );
    });

    it('should reject invalid email', async () => {
      mockRequest.body = {
        username: 'testuser',
        email: 'invalid-email',
        phone_number: '1234567890',
        password: 'Password@123',
        age: 25,
      };

      await register(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(400);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'Invalid email address' });
    });

    it('should reject invalid phone number', async () => {
      mockRequest.body = {
        username: 'testuser',
        email: 'test@example.com',
        phone_number: '123',  // Too short
        password: 'Password@123',
        age: 25,
      };

      await register(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(400);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'Phone number must be 10 digits' });
    });

    it('should reject weak password', async () => {
      mockRequest.body = {
        username: 'testuser',
        email: 'test@example.com',
        phone_number: '1234567890',
        password: 'weak',  // No special char and too short
        age: 25,
      };

      await register(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(400);
      expect(jsonMock).toHaveBeenCalledWith(
        expect.objectContaining({ message: expect.stringContaining('Password') })
      );
    });

    it('should reject if user already exists', async () => {
      mockRequest.body = {
        username: 'testuser',
        email: 'test@example.com',
        phone_number: '1234567890',
        password: 'Password@123',
        age: 25,
      };

      (db.query as jest.Mock).mockResolvedValueOnce([[{ user_id: 1 }]]);

      await register(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(400);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'Username or email already exists' });
    });

    it('should reject age below 13', async () => {
      mockRequest.body = {
        username: 'testuser',
        email: 'test@example.com',
        phone_number: '1234567890',
        password: 'Password@123',
        age: 12,
      };

      await register(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(400);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'Must be at least 13 years old' });
    });
  });

  describe('login', () => {
    it('should login user successfully', async () => {
      mockRequest.body = {
        username: 'testuser',
        password: 'Password@123',
        platform: 'web',
      };

      const mockUser = {
        user_id: 1,
        username: 'testuser',
        password: 'hashedPassword',
      };

      (db.query as jest.Mock)
        .mockResolvedValueOnce([[]])  // No admin found
        .mockResolvedValueOnce([[mockUser]])  // User found
        .mockResolvedValueOnce([{ affectedRows: 1 }]); // Update last login
      
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      (jwt.sign as jest.Mock).mockReturnValue('test-token');

      await login(mockRequest as Request, mockResponse as Response);

      expect(jsonMock).toHaveBeenCalledWith(
        expect.objectContaining({
          message: 'Login successful',
          role: 'user',
          userId: 1,
          accessToken: 'test-token',
        })
      );
    });

    it('should login admin successfully', async () => {
      mockRequest.body = {
        username: 'admin',
        password: 'Admin@123',
        platform: 'web',
      };

      const mockAdmin = {
        admin_id: 1,
        username: 'admin',
        password: 'hashedPassword',
      };

      (db.query as jest.Mock)
        .mockResolvedValueOnce([[mockAdmin]])  // Admin found
        .mockResolvedValueOnce([{ affectedRows: 1 }]); // Update last login
      
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      (jwt.sign as jest.Mock).mockReturnValue('admin-token');

      await login(mockRequest as Request, mockResponse as Response);

      expect(jsonMock).toHaveBeenCalledWith(
        expect.objectContaining({
          message: 'Login successful',
          role: 'admin',
          userId: 1,
          accessToken: 'admin-token',
        })
      );
    });

    it('should reject invalid username', async () => {
      mockRequest.body = {
        username: 'nonexistent',
        password: 'Password@123',
        platform: 'web',
      };

      (db.query as jest.Mock)
        .mockResolvedValueOnce([[]])  // No admin
        .mockResolvedValueOnce([[]]);  // No user

      await login(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(400);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'Invalid username or password' });
    });

    it('should reject invalid password', async () => {
      mockRequest.body = {
        username: 'testuser',
        password: 'wrongpassword',
        platform: 'web',
      };

      const mockUser = {
        user_id: 1,
        username: 'testuser',
        password: 'hashedPassword',
      };

      (db.query as jest.Mock)
        .mockResolvedValueOnce([[]])  // No admin
        .mockResolvedValueOnce([[mockUser]]);  // User found
      
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      await login(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(400);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'Invalid username or password' });
    });

    it('should include refresh token for mobile users', async () => {
      mockRequest.body = {
        username: 'testuser',
        password: 'Password@123',
        platform: 'mobile',
      };

      const mockUser = {
        user_id: 1,
        username: 'testuser',
        password: 'hashedPassword',
      };

      (db.query as jest.Mock)
        .mockResolvedValueOnce([[]])  // No admin
        .mockResolvedValueOnce([[mockUser]])  // User found
        .mockResolvedValueOnce([{ affectedRows: 1 }]); // Update refresh token
      
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      (jwt.sign as jest.Mock)
        .mockReturnValueOnce('access-token')
        .mockReturnValueOnce('refresh-token');

      await login(mockRequest as Request, mockResponse as Response);

      expect(jsonMock).toHaveBeenCalledWith(
        expect.objectContaining({
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
        })
      );
    });
  });

  describe('refreshToken', () => {
    it('should refresh token successfully', async () => {
      mockRequest.body = {
        refreshToken: 'valid-refresh-token',
      };

      const mockUser = {
        user_id: 1,
        refresh_token: 'valid-refresh-token',
      };

      (db.query as jest.Mock).mockResolvedValueOnce([[mockUser]]);
      (jwt.verify as jest.Mock).mockReturnValue({ id: 1, role: 'user' });
      (jwt.sign as jest.Mock).mockReturnValue('new-access-token');

      await refreshToken(mockRequest as Request, mockResponse as Response);

      expect(jsonMock).toHaveBeenCalledWith({
        accessToken: 'new-access-token',
        expiresIn: '30m',
      });
    });

    it('should reject missing refresh token', async () => {
      mockRequest.body = {};

      await refreshToken(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(401);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'No refresh token provided' });
    });

    it('should reject expired refresh token', async () => {
      mockRequest.body = {
        refreshToken: 'expired-token',
      };

      (db.query as jest.Mock).mockResolvedValueOnce([[]]);

      await refreshToken(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(403);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'Invalid or expired refresh token' });
    });
  });

  describe('logout', () => {
    it('should logout successfully', async () => {
      (mockRequest as any).user = { id: 1, role: 'user' };

      (db.query as jest.Mock).mockResolvedValueOnce([{ affectedRows: 1 }]);

      await logout(mockRequest as Request, mockResponse as Response);

      expect(jsonMock).toHaveBeenCalledWith({ message: 'Logged out successfully' });
    });

    it('should reject unauthorized logout', async () => {
      (mockRequest as any).user = undefined;

      await logout(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(401);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'Unauthorized: Missing user ID' });
    });
  });

  describe('deleteOwnAccount', () => {
    it('should delete account successfully', async () => {
      (mockRequest as any).user = { id: 1 };

      (db.query as jest.Mock)
        .mockResolvedValueOnce([[{ image_profile: null }]])  // Get user
        .mockResolvedValueOnce([{ affectedRows: 1 }])  // Delete meal details
        .mockResolvedValueOnce([{ affectedRows: 1 }])  // Delete meals
        .mockResolvedValueOnce([{ affectedRows: 1 }])  // Delete activity details
        .mockResolvedValueOnce([{ affectedRows: 1 }])  // Delete activities
        .mockResolvedValueOnce([{ affectedRows: 1 }])  // Delete daily calories
        .mockResolvedValueOnce([{ affectedRows: 1 }])  // Delete AI analysis
        .mockResolvedValueOnce([{ affectedRows: 1 }]);  // Delete user

      await deleteOwnAccount(mockRequest as Request, mockResponse as Response);

      expect(jsonMock).toHaveBeenCalledWith({ message: 'Account deleted successfully' });
    });

    it('should reject if user not found', async () => {
      (mockRequest as any).user = { id: 999 };

      (db.query as jest.Mock).mockResolvedValueOnce([[]]);

      await deleteOwnAccount(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(404);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'User not found' });
    });
  });
});
