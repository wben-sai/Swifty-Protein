import {
  Controller,
  Param,
  Post,
  Delete,
  Req,
  UseGuards,
} from "@nestjs/common";
import type { Request } from "express";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard.js";
import { FavoritesService } from "./favorites.service.js";

@Controller("favorites")
export class FavoritesController {
  constructor(
    private readonly favoritesService: FavoritesService,
  ) {}

  @UseGuards(JwtAuthGuard)
  @Post(":moleculeId")
  addFavorite(
    @Param("moleculeId") moleculeId: string,
    @Req() request: Request,
  ) {
    const userId = (request as any).user.userId;

    return this.favoritesService.addFavorite(
      userId,
      moleculeId,
    );
  }

  @UseGuards(JwtAuthGuard)
  @Delete(":moleculeId")
  removeFavorite(
    @Param("moleculeId") moleculeId: string,
    @Req() request: Request,
  ) {
    const userId = (request as any).user.userId;

    return this.favoritesService.removeFavorite(
      userId,
      moleculeId,
    );
  }
}