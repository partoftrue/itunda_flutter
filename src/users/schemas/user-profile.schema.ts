import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type UserProfileDocument = UserProfile & Document;

@Schema({ timestamps: true })
export class UserProfile {
  @Prop({ required: true })
  userId: string;

  @Prop()
  avatar: string;

  @Prop()
  bio: string;

  @Prop()
  address: string;

  @Prop()
  city: string;

  @Prop()
  state: string;

  @Prop()
  postalCode: string;

  @Prop()
  country: string;

  @Prop({ type: Object })
  socialLinks: {
    twitter?: string;
    facebook?: string;
    linkedin?: string;
    instagram?: string;
  };

  @Prop({ type: [String] })
  interests: string[];

  @Prop({ type: Object })
  financialGoals: {
    savingsTarget?: number;
    investmentTarget?: number;
    debtReductionTarget?: number;
  };

  @Prop({ type: Object })
  preferences: {
    theme?: string;
    notifications?: {
      email?: boolean;
      push?: boolean;
      sms?: boolean;
    };
    dashboardLayout?: string;
  };
}

export const UserProfileSchema = SchemaFactory.createForClass(UserProfile); 