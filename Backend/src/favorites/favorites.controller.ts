import { Controller, Get, Req, UseGuards } from "@nestjs/common";
import express from "express";
import { JwtAuthGuard } from  "../auth/guards/jwt-auth.guard.js";

@Controller("favorites")
export class FavoritesController {
  @UseGuards(JwtAuthGuard)
  @Get("test")
  test(@Req() request: express.Request) {
    return {
      message: "JWT is valid",
      user: request.user,
    };
  }
}