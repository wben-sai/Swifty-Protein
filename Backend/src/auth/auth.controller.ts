import { AuthService } from "./auth.service.js";
import { Body, Controller, Post } from "@nestjs/common";
import { RegisterDto } from "./dto/register.dto.js";


@Controller("auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post("register")
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }
}