import { Module } from '@nestjs/common';
import { PrismaModule } from "./prisma/prisma.module";
import { AuthModule } from './auth/auth.module';
import { FavoritesModule } from "./favorites/favorites.module.js";
import { MoleculesModule } from './molecules/molecules.module';


@Module({
  imports: [PrismaModule, AuthModule, FavoritesModule, MoleculesModule],
})
export class AppModule {}