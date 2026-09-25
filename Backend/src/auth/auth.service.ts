import {
  ConflictException,
  Injectable,
} from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service.js";
import { RegisterDto } from "./dto/register.dto.js";
import * as argon2 from "argon2";
import { JwtService } from "@nestjs/jwt";
import { LoginDto } from "./dto/login.dto.js";
import { UnauthorizedException } from "@nestjs/common";



@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    ) {}

  async register(dto: RegisterDto) {//what if the user data doesnt pass the validation?
    const existingUser = await this.prisma.user.findUnique({//In casae of db down, credentials not valid ... prisma throws an error, nest catch and return 500 internal server error
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

  async login(dto: LoginDto) {
  const user = await this.prisma.user.findUnique({
    where: {
      email: dto.email,
    },
  });

  if (!user) {
    throw new UnauthorizedException("Invalid credentials");
  }

  const passwordValid = await argon2.verify(
    user.passwordHash,
    dto.password,
  );

  if (!passwordValid) {
    throw new UnauthorizedException("Invalid credentials");
  }

  const accessToken = this.jwtService.sign({
    sub: user.id,
    email: user.email,
  });

  return {
    accessToken,
  };
}
}