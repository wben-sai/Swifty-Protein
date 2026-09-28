import { Module } from '@nestjs/common';
import { PrismaModule } from "./prisma/prisma.module";
import { AuthModule } from './auth/auth.module';
import { FavoritesModule } from "./favorites/favorites.module.js";


@Module({
  imports: [PrismaModule, AuthModule, FavoritesModule],
})
export class AppModule {}