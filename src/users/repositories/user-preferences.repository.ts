import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

@Injectable()
export class UserPreferencesRepository {
  private readonly redisClient: Redis;
  private readonly prefixKey = 'user:preferences:';

  constructor(private readonly configService: ConfigService) {
    this.redisClient = new Redis({
      host: this.configService.get<string>('REDIS_HOST'),
      port: this.configService.get<number>('REDIS_PORT'),
    });
  }

  /**
   * Save user preferences to Redis
   */
  async savePreferences(userId: string, preferences: Record<string, any>): Promise<void> {
    await this.redisClient.set(
      `${this.prefixKey}${userId}`,
      JSON.stringify(preferences),
    );
  }

  /**
   * Get user preferences from Redis
   */
  async getPreferences(userId: string): Promise<Record<string, any> | null> {
    const data = await this.redisClient.get(`${this.prefixKey}${userId}`);
    if (!data) return null;
    
    try {
      return JSON.parse(data);
    } catch (error) {
      return null;
    }
  }

  /**
   * Update specific preference fields
   */
  async updatePreferences(
    userId: string,
    preferences: Record<string, any>,
  ): Promise<void> {
    const existingPrefs = await this.getPreferences(userId) || {};
    const updatedPrefs = { ...existingPrefs, ...preferences };
    
    await this.savePreferences(userId, updatedPrefs);
  }

  /**
   * Delete user preferences
   */
  async deletePreferences(userId: string): Promise<void> {
    await this.redisClient.del(`${this.prefixKey}${userId}`);
  }
} 