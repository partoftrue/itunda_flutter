import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { UsersService } from '../../users/users.service';

interface JwtPayload {
  sub: string;
  email: string;
  iat: number;
  exp: number;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private readonly configService: ConfigService,
    private readonly usersService: UsersService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: configService.get('JWT_SECRET') || 'super-secret',
      ignoreExpiration: false,
    });
  }

  async validate(payload: JwtPayload) {
    const { sub: id } = payload;
    
    try {
      // Find user by id
      const user = await this.usersService.findById(id);
      
      // Check if user is active
      if (user.status !== 'active') {
        throw new UnauthorizedException('User account is inactive or suspended');
      }
      
      // Return user object (without password)
      delete user.password;
      return user;
    } catch (error) {
      throw new UnauthorizedException('Invalid token');
    }
  }
} 