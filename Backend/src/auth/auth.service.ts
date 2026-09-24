import {
  ConflictException,
  Injectable,
} from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service.js";
import { RegisterDto } from "./dto/register.dto.js";
import * as argon2 from "argon2";
import { JwtService } from "@nestjs/jwt";



@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    ) {}

  async register(dto: RegisterDto) {
    const existingUser = await this.prisma.user.findUnique({
      where: {
        email: dto.email,
      },
    });

    if (existingUser) {
      throw new ConflictException("Email already registered");
    }
    const passwordHash = await argon2.hash(dto.password);
    const user = await this.prisma.user.create({
    data: {
        firstName: dto.firstName,
        lastName: dto.lastName,
        email: dto.email,
        passwordHash,
    }});
    const accessToken = this.jwtService.sign({
        sub: user.id,
        email: user.email,
        });
    return { accessToken };
  }
}