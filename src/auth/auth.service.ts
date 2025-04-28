import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { UsersService } from '../users/users.service';
import { User } from '../users/entities/user.entity';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * Validate user credentials
   */
  async validateUser(email: string, password: string): Promise<any> {
    try {
      // Find user by email (including password)
      const user = await this.usersService.findByEmail(email);
      
      // Check if user exists and password is correct
      if (user && (await bcrypt.compare(password, user.password))) {
        // Update last login timestamp
        await this.usersService.update(user.id, { lastLogin: new Date() });
        
        // Return user without password
        const { password, ...result } = user;
        return result;
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  /**
   * Login user and generate JWT token
   */
  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;
    
    // Validate user credentials
    const user = await this.validateUser(email, password);
    
    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }
    
    // Check if user is active
    if (user.status !== 'active') {
      throw new UnauthorizedException('Account is inactive or suspended');
    }
    
    // Generate JWT token
    const payload = { email: user.email, sub: user.id };
    
    return {
      access_token: this.jwtService.sign(payload),
      user,
    };
  }

  /**
   * Register new user
   */
  async register(registerDto: RegisterDto) {
    // Create new user
    const user = await this.usersService.create(registerDto);
    
    // Generate JWT token
    const payload = { email: user.email, sub: user.id };
    
    return {
      access_token: this.jwtService.sign(payload),
      user,
    };
  }

  /**
   * Get user profile from JWT token
   */
  async getProfile(user: User) {
    return user;
  }
} 