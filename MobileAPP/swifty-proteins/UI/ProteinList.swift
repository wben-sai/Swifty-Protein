//
//  ligands.swift
//  swifty-proteins
//
//  Created by XPI-9 on 9/8/2026.
//

import SwiftUI

struct LigandStore {
    static func load(from filename: String = "ligands", withExtension ext: String = "txt") -> [String] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext), let contents = try? String(contentsOf: url, encoding: .utf8) else {
           return []
        }
        return contents.split(whereSeparator: { $0.isWhitespace }) .map(String.init)
    }
}

struct ProteinList: View {
    @State private var allItems: [String] = LigandStore.load()
    @State private var searchText: String = ""

    private var filteredItems: [String] {
        guard !searchText.isEmpty else { return allItems }
        return allItems.filter {
            $0.range(of: searchText, options: .caseInsensitive) != nil
        }
    }

    var body: some View {
        NavigationView {
            List(filteredItems, id: \.self) { item in
                NavigationLink {
                    ProteinDetails(ligandID: item)
                } label: {
                   Text(item)
                       .font(.system(.body, design: .monospaced))
               }
            }
            .listStyle(.plain)
            .navigationTitle("Ligand IDs")
            .overlay {
                if filteredItems.isEmpty && !searchText.isEmpty {
                    emptyStateView
                }
            }
        }
        .navigationViewStyle(.stack)
        .searchable(text: $searchText, prompt: "Search ligand identifiers")
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text("No Results")
                .font(.headline)
            Text("No ligand identifiers match \u{201C}\(searchText)\u{201D}")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}
