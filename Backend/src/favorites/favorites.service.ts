import { Injectable } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service.js";

@Injectable()
export class FavoritesService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async addFavorite(
    userId: number,
    moleculeId: string,
  ) {
    return this.prisma.favorite.create({
      data: {
        userId,
        moleculeId,
      },
    });
  }

  async removeFavorite(
    userId: number,
    moleculeId: string,
  ) {
    return this.prisma.favorite.delete({
      where: {
        userId_moleculeId: {
          userId,
          moleculeId,
        },
      },
    });
  }
}