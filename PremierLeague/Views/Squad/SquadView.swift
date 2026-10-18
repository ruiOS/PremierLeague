//
//  SquadView.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import SwiftUI

// MARK: - Squad View (SwiftUI)
struct SquadView: View {

    // MARK: Dependencies
    @ObservedObject var viewModel: SquadViewModel

    // MARK: State
    @State private var searchText: String = ""
    @State private var debounceTask: Task<Void, Never>?

    // MARK: Init
    init(viewModel: SquadViewModel) {
        self.viewModel = viewModel
    }

    // MARK: Body
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            contentView
        }
        .navigationTitle(viewModel.teamName)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search players…"
        )
        .onChange(of: searchText) { newQuery in
            handleSearchChange(newQuery)
        }
    }

    // MARK: Content States
    @ViewBuilder
    private var contentView: some View {
        if viewModel.contentState.isEmpty {
            VStack(spacing: 8) {
                Spacer()

                Image(systemName: "person.slash")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
                    .padding(.bottom, 4)

                Text("No players match your search.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()
            }
        } else {
            playersList
        }
    }

    // MARK: Players List
    private var playersList: some View {
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.sections) { section in
                    Section {
                        LazyVStack(spacing: 10) {
                            ForEach(section.players) { player in
                                PlayerCell(
                                    player: player,
                                    positionShortName: player.elementType.shortName
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.top, 4)
                    } header: {
                        PositionHeaderView(
                            title: section.title,
                            count: section.players.count
                        )
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: Search Debounce
    private func handleSearchChange(_ query: String) {
        debounceTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            viewModel.updateSearch(query: "")
            return
        }

        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            if !Task.isCancelled {
                viewModel.updateSearch(query: query)
            }
        }
    }
}
