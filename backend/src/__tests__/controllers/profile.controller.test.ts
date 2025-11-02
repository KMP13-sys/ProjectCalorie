import { Request, Response } from 'express';
import { getUserProfile, updateProfileImage } from '../../controllers/profile.controller';
import { getUserById } from '../../models/userModel';
import db from '../../config/db';

jest.mock('../../models/userModel');
jest.mock('../../config/db');

describe('Profile Controller', () => {
  let mockRequest: Partial<Request>;
  let mockResponse: Partial<Response>;
  let jsonMock: jest.Mock;
  let statusMock: jest.Mock;

  beforeEach(() => {
    jsonMock = jest.fn();
    statusMock = jest.fn().mockReturnValue({ json: jsonMock });
    
    mockRequest = {
      params: {},
      protocol: 'http',
      get: jest.fn().mockReturnValue('localhost:3000'),
    };
    
    mockResponse = {
      status: statusMock,
      json: jsonMock,
    };

    jest.clearAllMocks();
  });

  describe('getUserProfile', () => {
    it('should get user profile successfully', async () => {
      mockRequest.params = { id: '1' };

      const mockUser = {
        user_id: 1,
        username: 'testuser',
        email: 'test@example.com',
        password: 'hashedPassword',
        refresh_token: 'token',
        refresh_token_expires_at: new Date(),
        image_profile: 'profile.jpg',
        age: 25,
        gender: 'male',
        height: 175,
        weight: 70,
      };

      (getUserById as jest.Mock).mockResolvedValue(mockUser);

      await getUserProfile(mockRequest as Request, mockResponse as Response);

      expect(jsonMock).toHaveBeenCalledWith(
        expect.objectContaining({
          user_id: 1,
          username: 'testuser',
          email: 'test@example.com',
          image_profile_url: 'http://localhost:3000/uploads/profile.jpg',
        })
      );
      expect(jsonMock).not.toHaveBeenCalledWith(
        expect.objectContaining({ password: expect.anything() })
      );
    });

    it('should reject invalid user id', async () => {
      mockRequest.params = { id: 'invalid' };

      await getUserProfile(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(400);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'Invalid user id' });
    });

    it('should return 404 if user not found', async () => {
      mockRequest.params = { id: '999' };
      (getUserById as jest.Mock).mockResolvedValue(null);

      await getUserProfile(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(404);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'User not found' });
    });

    it('should handle server errors', async () => {
      mockRequest.params = { id: '1' };
      (getUserById as jest.Mock).mockRejectedValue(new Error('Database error'));

      await getUserProfile(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(500);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'Server error' });
    });
  });

  describe('updateProfileImage', () => {
    it('should update profile image successfully', async () => {
      mockRequest.params = { id: '1' };
      (mockRequest as any).user = { id: 1 };
      (mockRequest as any).file = {
        filename: 'new-profile.jpg',
      };

      const mockUser = {
        user_id: 1,
        username: 'testuser',
        image_profile: 'old-profile.jpg',
      };

      (getUserById as jest.Mock).mockResolvedValue(mockUser);
      (db.query as jest.Mock).mockResolvedValue([{ affectedRows: 1 }]);

      await updateProfileImage(mockRequest as Request, mockResponse as Response);

      expect(jsonMock).toHaveBeenCalledWith({
        message: 'Profile image updated successfully',
        image_url: 'http://localhost:3000/uploads/new-profile.jpg',
      });
    });

    it('should reject unauthorized update', async () => {
      mockRequest.params = { id: '1' };
      (mockRequest as any).user = undefined;

      await updateProfileImage(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(401);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'Authentication failed' });
    });

    it('should reject forbidden update (different user)', async () => {
      mockRequest.params = { id: '2' };
      (mockRequest as any).user = { id: 1 };

      await updateProfileImage(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(403);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'Forbidden' });
    });

    it('should reject if no image uploaded', async () => {
      mockRequest.params = { id: '1' };
      (mockRequest as any).user = { id: 1 };
      (mockRequest as any).file = undefined;

      await updateProfileImage(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(400);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'No image uploaded' });
    });

    it('should return 404 if user not found', async () => {
      mockRequest.params = { id: '1' };
      (mockRequest as any).user = { id: 1 };
      (mockRequest as any).file = { filename: 'new-profile.jpg' };

      (getUserById as jest.Mock).mockResolvedValue(null);

      await updateProfileImage(mockRequest as Request, mockResponse as Response);

      expect(statusMock).toHaveBeenCalledWith(404);
      expect(jsonMock).toHaveBeenCalledWith({ message: 'User not found' });
    });
  });
});
