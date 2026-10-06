//
//  Dashboard.swift
//  swifty-proteins
//
//  Created by XPI-9 on 2/9/2026.
//

import SwiftUI
import Combine
import UIKit

struct LigandStore {
    static func load(from filename: String = "ligands", withExtension ext: String = "txt") -> [String] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext),
              let contents = try? String(contentsOf: url, encoding: .utf8) else {
            return []
        }
        return contents.split(whereSeparator: { $0.isWhitespace }).map(String.init)
    }
}

/// Persists favorite ligand IDs in UserDefaults.
final class FavoritesStore: ObservableObject {
    private let key = "favoriteLigandIDs"

    @Published private(set) var ids: [String] {
        didSet { UserDefaults.standard.set(ids, forKey: key) }
    }

    init() {
        self.ids = UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    func contains(_ id: String) -> Bool { ids.contains(id) }

    func toggle(_ id: String) {
        if let index = ids.firstIndex(of: id) {
            ids.remove(at: index)
        } else {
            ids.append(id)
        }
    }

    func clear() { ids.removeAll() }
}

// MARK: - Design System (reads everything from AppConfig.shared.theme)

enum DS {
    static var bg: Color { AppConfig.shared.theme.background }
    static var ink: Color { AppConfig.shared.theme.font }
    static var sub: Color { AppConfig.shared.theme.subText }
    static var card: Color { AppConfig.shared.theme.card }
    static var accentColor: Color { AppConfig.shared.theme.accent }

    static var accent: LinearGradient {
        LinearGradient(
            colors: [accentColor, accentColor.opacity(0.7)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    /// Stable per-ID variation of the accent (String.hashValue changes between launches).
    static func gradient(for id: String) -> LinearGradient {
        let seed = id.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        let strength = 0.72 + Double(seed % 4) * 0.09   // 0.72 … 0.99
        return LinearGradient(
            colors: [accentColor.opacity(strength), accentColor.opacity(strength * 0.7)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    static var danger: LinearGradient {
        LinearGradient(colors: [Color.red.opacity(0.75), Color.red],
                       startPoint: .top, endPoint: .bottom)
    }
}

enum Haptics {
    static func tap() {
        let enabled = UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

/// Soft glowing background shared by every screen.
struct Backdrop: View {
    var body: some View {
        ZStack {
            DS.bg
            Circle()
                .fill(DS.accentColor.opacity(0.20))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: -140, y: -300)
            Circle()
                .fill(DS.accentColor.opacity(0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 90)
                .offset(x: 170, y: -160)
        }
        .ignoresSafeArea()
    }
}

struct CardStyle: ViewModifier {
    var radius: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(DS.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(DS.ink.opacity(0.06), lineWidth: 1)
            )
    }
}

extension View {
    func card(radius: CGFloat = 20) -> some View { modifier(CardStyle(radius: radius)) }
}

struct ScreenHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(DS.ink)
            Text(subtitle)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(DS.sub)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}

struct EmptyState: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(DS.accentColor.opacity(0.12))
                    .frame(width: 96, height: 96)
                Circle()
                    .stroke(DS.accentColor.opacity(0.35), lineWidth: 1)
                    .frame(width: 96, height: 96)
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(DS.accent)
            }
            Text(title)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(DS.ink)
            Text(message)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(DS.sub)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Dashboard (ONE NavigationStack wrapping the TabView)

struct Dashboard: View {
    @StateObject private var favorites = FavoritesStore()
    @State private var allItems: [String] = LigandStore.load()
    @State private var selectedTab: Tab = .ligands

    enum Tab: Hashable { case ligands, favorites, settings }

    init() {
        // Frosted-glass tab bar
        let theme = AppConfig.shared.theme
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
        appearance.shadowColor = UIColor(theme.font).withAlphaComponent(0.08)

        let unselected = UIColor(theme.subText)
        for item in [appearance.stackedLayoutAppearance,
                     appearance.inlineLayoutAppearance,
                     appearance.compactInlineLayoutAppearance] {
            item.normal.iconColor = unselected
            item.normal.titleTextAttributes = [.foregroundColor: unselected]
        }
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                LigandsScreen(items: allItems)
                    .tabItem { Label("Ligands", systemImage: "atom") }
                    .tag(Tab.ligands)

                FavoritesScreen(items: allItems)
                    .tabItem { Label("Favorites", systemImage: "heart.fill") }
                    .tag(Tab.favorites)

                SettingsScreen(totalCount: allItems.count)
                    .tabItem { Label("Settings", systemImage: "person.crop.circle.fill") }
                    .tag(Tab.settings)
            }
            // The root uses custom headers; pushed screens get their own nav bar.
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(DS.accentColor)
        .environmentObject(favorites)
    }
}

/// Shared push destination: details screen without the tab bar.
struct LigandDestination: View {
    let ligandID: String

    var body: some View {
        ProteinDetails(ligandID: ligandID)
            .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Tab 1 · Ligand list

struct LigandsScreen: View {
    let items: [String]

    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    private var filtered: [String] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            Backdrop()

            VStack(spacing: 14) {
                ScreenHeader(
                    title: "Ligands",
                    subtitle: "\(filtered.count) of \(items.count) identifiers"
                )

                CustomSearchBar(text: $searchText, isFocused: $isSearchFocused)
                    .padding(.horizontal, 20)

                if filtered.isEmpty {
                    EmptyState(
                        icon: "magnifyingglass",
                        title: "No matches",
                        message: searchText.isEmpty
                            ? "No ligands were loaded."
                            : "Nothing found for \"\(searchText)\""
                    )
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(filtered, id: \.self) { item in
                                LigandRowLink(ligandID: item, highlight: searchText)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 2)
                        .padding(.bottom, 24)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
        }
    }
}

// MARK: - Tab 2 · Favorites

struct FavoritesScreen: View {
    @EnvironmentObject var favorites: FavoritesStore
    let items: [String]

    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var favoriteItems: [String] {
        let base = items.filter { favorites.contains($0) }
        guard !searchText.isEmpty else { return base }
        return base.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            Backdrop()

            VStack(spacing: 14) {
                ScreenHeader(
                    title: "Favorites",
                    subtitle: favorites.ids.isEmpty
                        ? "Your saved ligands live here"
                        : "\(favorites.ids.count) saved"
                )

                if favorites.ids.isEmpty {
                    EmptyState(
                        icon: "heart",
                        title: "Nothing here yet",
                        message: "Tap the heart on any ligand\nto keep it close."
                    )
                } else {
                    CustomSearchBar(text: $searchText, isFocused: $isSearchFocused)
                        .padding(.horizontal, 20)

                    if favoriteItems.isEmpty {
                        EmptyState(
                            icon: "magnifyingglass",
                            title: "No matches",
                            message: "Nothing found for \"\(searchText)\""
                        )
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(favoriteItems, id: \.self) { item in
                                    FavoriteCard(ligandID: item)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 2)
                            .padding(.bottom, 24)
                        }
                        .scrollDismissesKeyboard(.interactively)
                    }
                }
            }
        }
    }
}

struct FavoriteCard: View {
    let ligandID: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink {
                LigandDestination(ligandID: ligandID)
            } label: {
                VStack(alignment: .leading, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(DS.gradient(for: ligandID))
                            .frame(height: 78)
                        Text(ligandID.prefix(3).uppercased())
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(.white.opacity(0.95))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ligandID)
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(DS.ink)
                            .lineLimit(1)
                        Text("View structure")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(DS.sub)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .card(radius: 22)
            }
            .buttonStyle(.plain)

            FavoriteButton(ligandID: ligandID, onImage: true)
                .padding(.top, 18)
                .padding(.trailing, 18)
        }
    }
}

// MARK: - Favorite button

struct FavoriteButton: View {
    @EnvironmentObject var favorites: FavoritesStore
    let ligandID: String
    var onImage: Bool = false

    var body: some View {
        let isFav = favorites.contains(ligandID)

        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                favorites.toggle(ligandID)
            }
            Haptics.tap()
        } label: {
            Image(systemName: isFav ? "heart.fill" : "heart")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(
                    isFav
                    ? AnyShapeStyle(DS.danger)
                    : AnyShapeStyle(onImage ? Color.white : DS.sub)
                )
                .scaleEffect(isFav ? 1.15 : 1)
                .frame(width: 34, height: 34)
                .background(
                    Circle().fill(
                        onImage
                        ? Color.black.opacity(0.18)
                        : (isFav ? Color.red.opacity(0.12) : DS.ink.opacity(0.06))
                    )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tab 3 · Settings + Profile

struct SettingsScreen: View {
    @EnvironmentObject var favorites: FavoritesStore
    let totalCount: Int

    @AppStorage("profileName") private var name: String = ""
    @AppStorage("profileEmail") private var email: String = ""
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true

    @State private var showClearConfirm = false

    private var initials: String {
        let letters = name.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined()
        return letters.isEmpty ? "?" : letters.uppercased()
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        ZStack {
            Backdrop()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ScreenHeader(title: "Settings", subtitle: "Profile & preferences")
                        .padding(.horizontal, -20) // header already has its own padding

                    profileHero
                    statsRow

                    section("PROFILE") {
                        VStack(spacing: 0) {
                            FieldRow(icon: "person.fill", placeholder: "Your name", text: $name)
                            Divider().overlay(DS.ink.opacity(0.08)).padding(.leading, 62)
                            FieldRow(icon: "envelope.fill", placeholder: "Email address",
                                     text: $email, keyboard: .emailAddress)
                        }
                    }

                    section("PREFERENCES") {
                        HStack(spacing: 12) {
                            IconBadge(systemName: "iphone.radiowaves.left.and.right")
                            Text("Haptic feedback")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(DS.ink)
                            Spacer()
                            Toggle("", isOn: $hapticsEnabled)
                                .labelsHidden()
                                .tint(DS.accentColor)
                        }
                        .padding(14)
                    }

                    section("DATA") {
                        Button {
                            showClearConfirm = true
                        } label: {
                            HStack(spacing: 12) {
                                IconBadge(systemName: "trash.fill", gradient: DS.danger)
                                Text("Clear favorites")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(favorites.ids.isEmpty ? DS.sub : Color.red)
                                Spacer()
                            }
                            .padding(14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(favorites.ids.isEmpty)
                    }

                    Text("Swifty Proteins · v\(appVersion)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(DS.sub)
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .confirmationDialog("Remove all favorites?",
                            isPresented: $showClearConfirm,
                            titleVisibility: .visible) {
            Button("Clear favorites", role: .destructive) {
                withAnimation { favorites.clear() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: Pieces

    private var profileHero: some View {
        VStack(spacing: 0) {
            DS.accent
                .frame(height: 110)
                .overlay(alignment: .topTrailing) {
                    Circle().fill(Color.white.opacity(0.14))
                        .frame(width: 130, height: 130)
                        .offset(x: 35, y: -45)
                }
                .overlay(alignment: .bottomLeading) {
                    Circle().fill(Color.white.opacity(0.10))
                        .frame(width: 90, height: 90)
                        .offset(x: -25, y: 35)
                }
                .clipped()

            ZStack {
                Circle().fill(DS.bg).frame(width: 96, height: 96)
                Circle().fill(DS.accent).frame(width: 86, height: 86)
                Text(initials)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .offset(y: -48)
            .padding(.bottom, -48)

            VStack(spacing: 4) {
                Text(name.isEmpty ? "Add your name" : name)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(DS.ink)
                Text(email.isEmpty ? "No email set" : email)
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundColor(DS.sub)
            }
            .padding(.top, 10)
            .padding(.bottom, 22)
        }
        .frame(maxWidth: .infinity)
        .card(radius: 28)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatTile(icon: "heart.fill", value: "\(favorites.ids.count)", label: "Favorites",
                     gradient: DS.danger)
            StatTile(icon: "atom", value: "\(totalCount)", label: "Ligands", gradient: DS.accent)
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundColor(DS.sub)
                .padding(.leading, 6)
            content().card()
        }
    }
}

struct IconBadge: View {
    let systemName: String
    var gradient: LinearGradient = DS.accent

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 34, height: 34)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(gradient)
            )
    }
}

struct FieldRow: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon)
            TextField(placeholder, text: $text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(DS.ink)
                .keyboardType(keyboard)
                .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                .autocorrectionDisabled()
        }
        .padding(14)
    }
}

struct StatTile: View {
    let icon: String
    let value: String
    let label: String
    let gradient: LinearGradient

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, gradient: gradient)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(DS.ink)
                Text(label)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(DS.sub)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .card()
    }
}

// MARK: - Search Bar

struct CustomSearchBar: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isFocused.wrappedValue ? DS.accentColor : DS.sub)

            TextField("Search ligand identifiers", text: $text)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(DS.ink)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused(isFocused)
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    withAnimation(.easeOut(duration: 0.15)) { text = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(DS.sub)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Capsule().fill(DS.card))
        .overlay(
            Capsule().stroke(
                isFocused.wrappedValue ? AnyShapeStyle(DS.accent) : AnyShapeStyle(DS.ink.opacity(0.06)),
                lineWidth: isFocused.wrappedValue ? 1.5 : 1
            )
        )
        .animation(.easeOut(duration: 0.18), value: isFocused.wrappedValue)
    }
}

// MARK: - Rows

/// Row + heart overlay (heart sits above the NavigationLink so tapping it doesn't navigate).
struct LigandRowLink: View {
    let ligandID: String
    let highlight: String

    var body: some View {
        ZStack(alignment: .trailing) {
            NavigationLink {
                LigandDestination(ligandID: ligandID)
            } label: {
                LigandRow(ligandID: ligandID, highlight: highlight)
            }
            .buttonStyle(.plain)

            FavoriteButton(ligandID: ligandID)
                .padding(.trailing, 14)
        }
    }
}

struct LigandRow: View {
    let ligandID: String
    let highlight: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(DS.gradient(for: ligandID))
                    .frame(width: 48, height: 48)
                Text(ligandID.prefix(2).uppercased())
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                highlightedText.lineLimit(1)
                Text("Ligand · tap to explore")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(DS.sub)
            }

            Spacer()

            // Space reserved for the heart overlay
            Color.clear.frame(width: 34, height: 34)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .card(radius: 20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var highlightedText: Text {
        let font = Font.system(.headline, design: .monospaced)

        guard !highlight.isEmpty,
              let range = ligandID.range(of: highlight, options: .caseInsensitive) else {
            return Text(ligandID).font(font).foregroundColor(DS.ink)
        }

        let before = String(ligandID[ligandID.startIndex..<range.lowerBound])
        let match = String(ligandID[range])
        let after = String(ligandID[range.upperBound...])

        return Text(before).font(font).foregroundColor(DS.ink)
        + Text(match).font(font).fontWeight(.heavy).foregroundColor(DS.accentColor)
        + Text(after).font(font).foregroundColor(DS.ink)
    }
}
