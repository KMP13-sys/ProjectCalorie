import { getUserById, updateUserById, User } from '../../models/userModel';
import pool from '../../config/db';

jest.mock('../../config/db');

describe('User Model', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getUserById', () => {
    it('should return user when found', async () => {
      const mockUser: User = {
        user_id: 1,
        username: 'testuser',
        email: 'test@example.com',
        password: 'hashedPassword',
        age: 25,
        gender: 'male',
        height: 175,
        weight: 70,
        goal: 'maintain weight',
      };

      (pool.query as jest.Mock).mockResolvedValue([[mockUser]]);

      const result = await getUserById(1);

      expect(result).toEqual(mockUser);
      expect(pool.query).toHaveBeenCalledWith(
        'SELECT * FROM users WHERE user_id = ?',
        [1]
      );
    });

    it('should return null when user not found', async () => {
      (pool.query as jest.Mock).mockResolvedValue([[]]);

      const result = await getUserById(999);

      expect(result).toBeNull();
    });

    it('should handle database errors', async () => {
      (pool.query as jest.Mock).mockRejectedValue(new Error('Database error'));

      await expect(getUserById(1)).rejects.toThrow('Database error');
    });
  });

  describe('updateUserById', () => {
    it('should update user successfully', async () => {
      const updateData: Partial<User> = {
        age: 26,
        weight: 72,
        goal: 'lose weight',
      };

      const updatedUser: User = {
        user_id: 1,
        username: 'testuser',
        email: 'test@example.com',
        password: 'hashedPassword',
        age: 26,
        gender: 'male',
        height: 175,
        weight: 72,
        goal: 'lose weight',
      };

      (pool.query as jest.Mock)
        .mockResolvedValueOnce([{ affectedRows: 1 }])  // Update query
        .mockResolvedValueOnce([[updatedUser]]);       // Select query

      const result = await updateUserById(1, updateData);

      expect(result).toEqual(updatedUser);
      expect(pool.query).toHaveBeenCalledWith(
        expect.stringContaining('UPDATE users SET'),
        expect.arrayContaining([26, 72, 'lose weight', 1])
      );
    });

    it('should return null when no fields to update', async () => {
      const result = await updateUserById(1, {});

      expect(result).toBeNull();
      expect(pool.query).not.toHaveBeenCalled();
    });

    it('should only update provided fields', async () => {
      const updateData: Partial<User> = {
        weight: 75,
      };

      const updatedUser: User = {
        user_id: 1,
        username: 'testuser',
        email: 'test@example.com',
        password: 'hashedPassword',
        age: 25,
        gender: 'male',
        height: 175,
        weight: 75,
        goal: 'maintain weight',
      };

      (pool.query as jest.Mock)
        .mockResolvedValueOnce([{ affectedRows: 1 }])
        .mockResolvedValueOnce([[updatedUser]]);

      const result = await updateUserById(1, updateData);

      expect(result).toEqual(updatedUser);
      expect(pool.query).toHaveBeenCalledWith(
        'UPDATE users SET weight = ? WHERE user_id = ?',
        [75, 1]
      );
    });

    it('should handle database errors', async () => {
      const updateData: Partial<User> = { age: 26 };
      (pool.query as jest.Mock).mockRejectedValue(new Error('Database error'));

      await expect(updateUserById(1, updateData)).rejects.toThrow('Database error');
    });

    it('should ignore undefined values', async () => {
      const updateData = {
        age: 26,
        weight: undefined,
        goal: 'lose weight' as const,
      };

      (pool.query as jest.Mock)
        .mockResolvedValueOnce([{ affectedRows: 1 }])
        .mockResolvedValueOnce([[{}]]);

      await updateUserById(1, updateData);

      expect(pool.query).toHaveBeenCalledWith(
        'UPDATE users SET age = ?, goal = ? WHERE user_id = ?',
        [26, 'lose weight', 1]
      );
    });
  });
});
