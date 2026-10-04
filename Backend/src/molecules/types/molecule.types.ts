export type ParsedMolecule = {
  id: string;
  name: string;
  type: string;
  formula: string;
  atoms: Atom[];
  bonds: Bond[];
};

export type Atom = {
  id: string;
  element: string;
  x: number;
  y: number;
  z: number;
};

export type Bond = {
  atom1: string;
  atom2: string;
  order: string;
};