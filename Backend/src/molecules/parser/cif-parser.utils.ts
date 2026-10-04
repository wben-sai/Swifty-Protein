import { atomsInfoIndex, bondsInfoIndex } from "./parser.types";

export function getValue(line: string): string {
  const firstSpace = line.search(/\s/);

  return line.slice(firstSpace).trim();
}

export function getAtomInfoIndex(lines: string[]): atomsInfoIndex {
    const atomInfoIndex: atomsInfoIndex = {
        id_i: -1,
        type_i: -1,
        a_i: -1,
        b_i: -1,
        c_i: -1,
        x_i: -1,
        y_i: -1,
        z_i: -1,
        atoms_start_i: -1,
    };

    let i = 0;
    while (lines[i].startsWith("_chem_comp_atom") == false)
        i++;
    let j = i;
    while (lines[i].startsWith("_chem_comp_atom") == true){
        if (lines[i].startsWith("_chem_comp_atom.atom_id"))
            atomInfoIndex.id_i = i-j;
        else if (lines[i].startsWith("_chem_comp_atom.type_symbol"))
            atomInfoIndex.type_i = i-j;
        else if (lines[i].startsWith("_chem_comp_atom.model_Cartn_x"))
            atomInfoIndex.x_i = i-j;
        else if (lines[i].startsWith("_chem_comp_atom.model_Cartn_y"))
            atomInfoIndex.y_i = i-j;
        else if (lines[i].startsWith("_chem_comp_atom.model_Cartn_z"))
            atomInfoIndex.z_i = i-j;
        else if (lines[i].startsWith("_chem_comp_atom.pdbx_model_Cartn_x_ideal"))
            atomInfoIndex.a_i = i-j;
        else if (lines[i].startsWith("_chem_comp_atom.pdbx_model_Cartn_y_ideal"))
            atomInfoIndex.b_i = i-j;
        else if (lines[i].startsWith("_chem_comp_atom.pdbx_model_Cartn_z_ideal"))
            atomInfoIndex.c_i = i-j;
        i++;
    }
    atomInfoIndex.atoms_start_i = i;
    return atomInfoIndex;
}

export function getBondInfoIndex(lines: string[]): bondsInfoIndex {
    const bondInfoIndex: bondsInfoIndex = {
        atom1_i: -1,
        atom2_i: -1,
        order_i: -1,
        bonds_start_i: -1,
    };

    let i = 0;
    while (lines[i].startsWith("_chem_comp_bond") == false)
        i++;
    let j = i;
    while (lines[i].startsWith("_chem_comp_bond") == true){
        if (lines[i].startsWith("_chem_comp_bond.atom_id_1"))
            bondInfoIndex.atom1_i = i-j;
        else if (lines[i].startsWith("_chem_comp_bond.atom_id_2"))
            bondInfoIndex.atom2_i = i-j;
        else if (lines[i].startsWith("_chem_comp_bond.value_order"))
            bondInfoIndex.order_i = i-j;
        i++;
    }
    bondInfoIndex.bonds_start_i = i;
    return bondInfoIndex;
}
