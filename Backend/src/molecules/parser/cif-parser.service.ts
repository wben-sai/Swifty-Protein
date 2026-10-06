import { Injectable } from "@nestjs/common";
import type { ParsedMolecule } from "../types/molecule.types.js";
import { getValue, getAtomInfoIndex, getBondInfoIndex } from "./cif-parser.utils.js";


@Injectable()
export class CifParserService {
  parse(cifText: string) {
    const lines = cifText.split("\n");
    const empty_line = lines[2] == "" ? true : false;
    const molecule: ParsedMolecule = {
        id: empty_line ? getValue(lines[3]) : getValue(lines[2]),
        name: empty_line ? getValue(lines[4]) : getValue(lines[3]),
        type: empty_line ? getValue(lines[5]) : getValue(lines[4]),
        formula: empty_line ? getValue(lines[7]) : getValue(lines[6]),
        atoms: [],
        bonds: [],
    };

    const atomInfoIndex = getAtomInfoIndex(lines);
    console.log(atomInfoIndex);
    let i = atomInfoIndex.atoms_start_i;
    while (lines[i][0] != "#") {
        const atomLine = lines[i].split(/\s+/);
        molecule.atoms.push({
            id: atomLine[atomInfoIndex.id_i],
            element: atomLine[atomInfoIndex.type_i],
            x: atomLine[atomInfoIndex.x_i] != "?" ? parseFloat(atomLine[atomInfoIndex.x_i]) : parseFloat(atomLine[atomInfoIndex.a_i]),
            y: atomLine[atomInfoIndex.y_i] != "?" ? parseFloat(atomLine[atomInfoIndex.y_i]) : parseFloat(atomLine[atomInfoIndex.b_i]),
            z: atomLine[atomInfoIndex.z_i] != "?" ? parseFloat(atomLine[atomInfoIndex.z_i]) : parseFloat(atomLine[atomInfoIndex.c_i]),
        });
        i++;
    }

    const bondInfoIndex = getBondInfoIndex(lines);
    i = bondInfoIndex.bonds_start_i;
    while (lines[i][0] != "#") {
        const bondLine = lines[i].split(/\s+/);
        molecule.bonds.push({
            atom1: bondLine[bondInfoIndex.atom1_i],
            atom2: bondLine[bondInfoIndex.atom2_i],
            order: bondLine[bondInfoIndex.order_i],
        });
        i++;
    }
    
    return molecule;
    }
}
