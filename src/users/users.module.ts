import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MongooseModule } from '@nestjs/mongoose';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { User } from './entities/user.entity';
import { UserProfile, UserProfileSchema } from './schemas/user-profile.schema';
import { UserPreferencesRepository } from './repositories/user-preferences.repository';

@Module({
  imports: [
    TypeOrmModule.forFeature([User]),
    MongooseModule.forFeature([
      { name: UserProfile.name, schema: UserProfileSchema },
    ]),
  ],
  controllers: [UsersController],
  providers: [UsersService, UserPreferencesRepository],
  exports: [UsersService],
})
export class UsersModule {} 