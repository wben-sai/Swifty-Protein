import { Module } from "@nestjs/common";
import { MoleculesController } from "./molecules.controller.js";
import { MoleculesService } from "./molecules.service.js";
import { CifParserService } from "./parser/cif-parser.service.js";

@Module({
  controllers: [MoleculesController],
  providers: [
    MoleculesService,
    CifParserService,
  ],
})
export class MoleculesModule {}