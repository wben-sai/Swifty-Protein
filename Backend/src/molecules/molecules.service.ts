import {
  BadGatewayException,
  Injectable,
} from "@nestjs/common";
import { CifParserService } from "./parser/cif-parser.service.js";

@Injectable()
export class MoleculesService {
    constructor(
        private readonly cifParserService: CifParserService,
    ) {}

  async fetchFromRcsb(moleculeId: string) {
    const url = `https://files.rcsb.org/ligands/view/${moleculeId}.cif`;

    try {
      const response = await fetch(url);

      if (!response.ok) {
        throw new BadGatewayException(
          `RCSB request failed, with status ${response.status}`,
        );
      }
      const cifText = await response.text();
      return this.cifParserService.parse(cifText);
    } 
    catch {
      throw new BadGatewayException(
        "Could not communicate with RCSB",
      );
    }
  }
}