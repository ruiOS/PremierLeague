//
//  TeamsView.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import SwiftUI

// MARK: - Teams View (SwiftUI)
struct TeamsView: View {

    // MARK: Dependencies
    @ObservedObject var viewModel: TeamsViewModel
    @ObservedObject var navigator: TeamsNavigator

    // MARK: State
    @State private var alertTitle: String = ""
    @State private var alertMessage: String?
    @State private var isShowingAlert: Bool = false

    // MARK: Init
    init(viewModel: TeamsViewModel, navigator: TeamsNavigator) {
        self.viewModel = viewModel
        self.navigator = navigator
    }

    // MARK: Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                contentView
            }
            .navigationTitle("Premier League")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.loadTeams(for: .pullToRefresh)
            }
            .onAppear {
                setupBindings()
                viewModel.loadTeams(for: .standard)
            }
            .alert(alertTitle, isPresented: $isShowingAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                if let alertMessage {
                    Text(alertMessage)
                }
            })
            .navigationDestination(item: $navigator.selectedTeam) { team in
                SquadViewBuilder().build(for: team)
            }
        }
    }

    // MARK: Content States
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .scaleEffect(1.3)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded:
            if viewModel.numberOfTeams == 0 {
                EmptyStateView(
                    icon: "sportscourt",
                    title: "No Teams Found",
                    message: "There are no teams to display at the moment.",
                    showRetry: false
                )
            } else {
                teamsList
            }

        case .failed(let error):
            if viewModel.numberOfTeams > 0 {
                teamsList
            } else {
                EmptyStateView(
                    icon: "wifi.slash",
                    title: "Unable to Load",
                    message: error.localizedDescription,
                    showRetry: true,
                    onRetry: {
                        viewModel.loadTeams(for: .standard)
                    }
                )
            }
        }
    }

    // MARK: Teams List
    private var teamsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(Array(viewModel.allTeams.enumerated()), id: \.element.id) { index, team in
                    Button {
                        viewModel.didSelectTeam(at: index)
                    } label: {
                        TeamCell(team: team)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 12)
        }
    }

    // MARK: Bindings
    private func setupBindings() {
        viewModel.refreshDidFail = { error in
            alertTitle = "Refresh Failed"
            alertMessage = error.localizedDescription
            isShowingAlert = true
        }

        viewModel.stateDidChange = { state in
            if case .failed(let error) = state, viewModel.numberOfTeams > 0 {
                alertTitle = "Error"
                alertMessage = error.localizedDescription
                isShowingAlert = true
            }
        }
    }
}
