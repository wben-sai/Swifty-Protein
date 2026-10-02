import {
  Controller,
  Get,
  Param,
} from "@nestjs/common";
import { MoleculesService } from "./molecules.service.js";

@Controller("molecules")
export class MoleculesController {
  constructor(
    private readonly moleculesService: MoleculesService,
  ) {}

  @Get(":moleculeId")
  getMolecule(
    @Param("moleculeId") moleculeId: string,
  ) {
    return this.moleculesService.fetchFromRcsb(moleculeId);
  }
}