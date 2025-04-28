import { Injectable, NotFoundException, ConflictException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import * as bcrypt from 'bcrypt';
import { User, UserStatus } from './entities/user.entity';
import { UserProfile, UserProfileDocument } from './schemas/user-profile.schema';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { UserPreferencesRepository } from './repositories/user-preferences.repository';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    
    @InjectModel(UserProfile.name)
    private userProfileModel: Model<UserProfileDocument>,
    
    private userPreferencesRepository: UserPreferencesRepository,
  ) {}

  /**
   * Create a new user
   */
  async create(createUserDto: CreateUserDto): Promise<User> {
    // Check if user with email already exists
    const existingUser = await this.usersRepository.findOne({
      where: { email: createUserDto.email },
    });

    if (existingUser) {
      throw new ConflictException('Email already in use');
    }

    // Hash password
    const hashedPassword = await this.hashPassword(createUserDto.password);

    // Create new user
    const newUser = this.usersRepository.create({
      ...createUserDto,
      password: hashedPassword,
    });

    // Save user
    const savedUser = await this.usersRepository.save(newUser);

    // Create empty user profile in MongoDB
    await this.userProfileModel.create({
      userId: savedUser.id,
    });

    // Return user without password
    delete savedUser.password;
    return savedUser;
  }

  /**
   * Find all users
   */
  async findAll(status?: UserStatus): Promise<User[]> {
    const query = this.usersRepository.createQueryBuilder('user');
    
    if (status) {
      query.where('user.status = :status', { status });
    }
    
    const users = await query.getMany();
    
    // Remove passwords from response
    users.forEach(user => {
      delete user.password;
    });
    
    return users;
  }

  /**
   * Find user by id
   */
  async findById(id: string): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { id } });

    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    // Remove password from response
    delete user.password;
    return user;
  }

  /**
   * Find user by email
   */
  async findByEmail(email: string): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { email } });

    if (!user) {
      throw new NotFoundException(`User with email ${email} not found`);
    }

    return user;
  }

  /**
   * Update user
   */
  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const user = await this.findById(id);

    // Check if email is being updated and if it's already in use
    if (updateUserDto.email && updateUserDto.email !== user.email) {
      const existingUser = await this.usersRepository.findOne({
        where: { email: updateUserDto.email },
      });

      if (existingUser) {
        throw new ConflictException('Email already in use');
      }
    }

    // Update user
    const updatedUser = await this.usersRepository.save({
      ...user,
      ...updateUserDto,
    });

    // Remove password from response
    delete updatedUser.password;
    return updatedUser;
  }

  /**
   * Update user password
   */
  async updatePassword(id: string, currentPassword: string, newPassword: string): Promise<void> {
    const user = await this.usersRepository.findOne({ where: { id } });

    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    // Verify current password
    const isPasswordValid = await bcrypt.compare(currentPassword, user.password);

    if (!isPasswordValid) {
      throw new BadRequestException('Current password is invalid');
    }

    // Hash new password
    const hashedPassword = await this.hashPassword(newPassword);

    // Update password
    user.password = hashedPassword;
    await this.usersRepository.save(user);
  }

  /**
   * Delete user
   */
  async remove(id: string): Promise<void> {
    const user = await this.findById(id);
    
    // Delete user profile from MongoDB
    await this.userProfileModel.deleteOne({ userId: id });
    
    // Delete user preferences from Redis
    await this.userPreferencesRepository.deletePreferences(id);
    
    // Delete user from MySQL
    await this.usersRepository.remove(user);
  }

  /**
   * Get user profile
   */
  async getUserProfile(userId: string): Promise<UserProfile> {
    const profile = await this.userProfileModel.findOne({ userId });

    if (!profile) {
      throw new NotFoundException(`Profile for user with ID ${userId} not found`);
    }

    return profile;
  }

  /**
   * Update user profile
   */
  async updateUserProfile(userId: string, profileData: Partial<UserProfile>): Promise<UserProfile> {
    // Ensure user exists
    await this.findById(userId);

    // Find and update profile
    const profile = await this.userProfileModel.findOneAndUpdate(
      { userId },
      { $set: profileData },
      { new: true, upsert: true },
    );

    return profile;
  }

  /**
   * Utility method to hash a password
   */
  private async hashPassword(password: string): Promise<string> {
    const salt = await bcrypt.genSalt();
    return bcrypt.hash(password, salt);
  }
} 