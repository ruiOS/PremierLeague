//
//  TeamsViewController.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import UIKit

// MARK: - Teams View Controller
final class TeamsViewController: UIViewController {

    // MARK: Dependencies
    private let viewModel: TeamsViewModelable

    // MARK: UI
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .systemGroupedBackground
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 80
        tv.register(TeamCell.self, forCellReuseIdentifier: TeamCell.reuseIdentifier)
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return rc
    }()

    private lazy var loadingSpinner: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        return ai
    }()

    private lazy var emptyStateView: EmptyStateView = {
        let v = EmptyStateView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        v.onRetry = { [weak self] in self?.loadData(for: .standard) }
        return v
    }()

    // MARK: Init
    init(viewModel: TeamsViewModelable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        bindViewModel()
        loadData(for: .standard)
    }

    // MARK: Setup
    private func setupLayout() {
        title = "Premier League"
        view.backgroundColor = .systemGroupedBackground
        tableView.addSubview(refreshControl)

        view.addSubview(tableView)
        view.addSubview(loadingSpinner)
        view.addSubview(emptyStateView)

        let emptyStateViewPadding: CGFloat = 32
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: emptyStateViewPadding),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -emptyStateViewPadding),
        ])
    }

    private func bindViewModel() {
        viewModel.stateDidChange = { [weak self] state in
            self?.handleStateChange(state)
        }
        viewModel.contentDidChange = { [weak self] in
            self?.handleContentChange()
        }
        viewModel.refreshDidFail = { [weak self] error in
            self?.handleRefreshError(error)
        }
    }

    // MARK: Data Loading

    private func loadData(for state: TeamsLoadTrigger) {
        viewModel.loadTeams(for: state)
    }

    @objc private func handleRefresh() {
        loadData(for: .pullToRefresh)
    }
}

// MARK: - MainActor UI Updates
@MainActor
private extension TeamsViewController {

    func handleStateChange(_ state: TeamsViewState) {
        render(state: state)
    }

    func handleContentChange() {
        tableView.reloadData()
    }

    func handleRefreshError(_ error: NetworkCallError) {
        let alert = UIAlertController(title: "Refresh Failed", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func render(state: TeamsViewState) {
        switch state {
        case .loading:
            renderLoading()
        case .loaded:
            renderLoaded()
        case .failed(let error):
            renderFailed(error)
        }
    }

    func renderLoading() {
        emptyStateView.isHidden = true
        tableView.isHidden = true
        loadingSpinner.startAnimating()
    }

    func renderLoaded() {
        loadingSpinner.stopAnimating()
        refreshControl.endRefreshing()

        if viewModel.numberOfTeams == 0 {
            tableView.isHidden = true
            emptyStateView.configure(
                icon: "sportscourt",
                title: "No Teams Found",
                message: "There are no teams to display at the moment.",
                showRetry: false
            )
            emptyStateView.isHidden = false
        } else {
            emptyStateView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }

    func renderFailed(_ error: NetworkCallError) {
        loadingSpinner.stopAnimating()
        refreshControl.endRefreshing()

        if viewModel.numberOfTeams > 0 {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        tableView.isHidden = true
        emptyStateView.configure(
            icon: "wifi.slash",
            title: "Unable to Load",
            message: error.localizedDescription,
            showRetry: true
        )
        emptyStateView.isHidden = false
    }
}

// MARK: UITableViewDataSource
extension TeamsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfTeams
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TeamCell.reuseIdentifier,
            for: indexPath
        ) as? TeamCell else {
            return UITableViewCell()
        }
        let team = viewModel.team(at: indexPath.row)
        cell.configure(with: team)
        return cell
    }
}

// MARK: UITableViewDelegate
extension TeamsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectTeam(at: indexPath.row)
    }
}
