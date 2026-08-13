//
//  CIFParser.swift
//  swifty-proteins
//
//  Created by XPI-9 on 12/8/2026.
//

import Foundation

struct Atom {
    let atomID: String
    let typeSymbol: String
    let charge: Int
    let x: Double?
    let y: Double?
    let z: Double?
}

struct Bond {
    let atomID1: String
    let atomID2: String
    let order: String
}

struct ChemComp {
    let id: String
    let name: String
    let formula: String
    let atoms: [Atom]
    let bonds: [Bond]
}

func tokenizeCIFLine(_ line: String) -> [String] {
    var tokens: [String] = []
    var current = ""
    var quote: Character? = nil
    let chars = Array(line)
    var i = 0

    while i < chars.count {
        let c = chars[i]
        if let q = quote {
            if c == q, (i + 1 == chars.count || chars[i + 1] == " " || chars[i + 1] == "\t") {
                quote = nil
                tokens.append(current)
                current = ""
            } else {
                current.append(c)
            }
        } else if c == " " || c == "\t" {
            if !current.isEmpty { tokens.append(current); current = "" }
        } else if (c == "'" || c == "\"") && current.isEmpty {
            quote = c
        } else {
            current.append(c)
        }
        i += 1
    }
    if !current.isEmpty { tokens.append(current) }
    return tokens
}


func parseData(from text: String) -> ChemComp? {
    let lines = text.components(separatedBy: "\n")
    var i = 0

    var id = "", name = "", formula = ""
    var atoms: [Atom] = []
    var bonds: [Bond] = []

    while i < lines.count {
        let line = lines[i].trimmingCharacters(in: .whitespaces)
        i += 1

        if line.isEmpty || line.hasPrefix("#") { continue }

        if line.hasPrefix("_chem_comp.") {
            let tokens = tokenizeCIFLine(line)
            guard tokens.count >= 2 else { continue }
            switch tokens[0] {
                case "_chem_comp.id":      id = tokens[1]
                case "_chem_comp.name":    name = tokens[1]
                case "_chem_comp.formula": formula = tokens[1]
                default: break
            }
            continue
        }

        if line == "loop_" {
            var columns: [String] = []
            while i < lines.count {
                let colLine = lines[i].trimmingCharacters(in: .whitespaces)
                guard colLine.hasPrefix("_") else { break }
                columns.append(colLine)
                i += 1
            }
            guard !columns.isEmpty else { continue }

            let isAtomLoop = columns[0].hasPrefix("_chem_comp_atom.")
            let isBondLoop = columns[0].hasPrefix("_chem_comp_bond.")

            let atomIDIdx   = columns.firstIndex(of: "_chem_comp_atom.atom_id")
            let typeIdx     = columns.firstIndex(of: "_chem_comp_atom.type_symbol")
            let chargeIdx   = columns.firstIndex(of: "_chem_comp_atom.charge")
            let xIdx        = columns.firstIndex(of: "_chem_comp_atom.pdbx_model_Cartn_x_ideal")
            let yIdx        = columns.firstIndex(of: "_chem_comp_atom.pdbx_model_Cartn_y_ideal")
            let zIdx        = columns.firstIndex(of: "_chem_comp_atom.pdbx_model_Cartn_z_ideal")

            let bondA1Idx   = columns.firstIndex(of: "_chem_comp_bond.atom_id_1")
            let bondA2Idx   = columns.firstIndex(of: "_chem_comp_bond.atom_id_2")
            let bondOrdIdx  = columns.firstIndex(of: "_chem_comp_bond.value_order")

            
            while i < lines.count {
                let rowLine = lines[i].trimmingCharacters(in: .whitespaces)
                if rowLine.isEmpty { i += 1; continue }
                if rowLine.hasPrefix("#") || rowLine.hasPrefix("loop_") || rowLine.hasPrefix("data_") || rowLine.hasPrefix("_") {
                    break
                }
                i += 1

                let values = tokenizeCIFLine(rowLine)
                guard values.count >= columns.count else { continue }

                if isAtomLoop {
                    let atomID = atomIDIdx.map { values[$0] } ?? ""
                    let type   = typeIdx.map { values[$0] } ?? ""
                    let charge = chargeIdx.flatMap { Int(values[$0]) } ?? 0
                    let x = xIdx.flatMap { Double(values[$0]) }
                    let y = yIdx.flatMap { Double(values[$0]) }
                    let z = zIdx.flatMap { Double(values[$0]) }
                    atoms.append(Atom(atomID: atomID, typeSymbol: type, charge: charge, x: x, y: y, z: z))
                } else if isBondLoop {
                    let a1 = bondA1Idx.map { values[$0] } ?? ""
                    let a2 = bondA2Idx.map { values[$0] } ?? ""
                    let ord = bondOrdIdx.map { values[$0] } ?? ""
                    bonds.append(Bond(atomID1: a1, atomID2: a2, order: ord))
                }
            }
            continue
        }
    }

    guard !id.isEmpty else { return nil }
    return ChemComp(id: id, name: name, formula: formula, atoms: atoms, bonds: bonds)
}
