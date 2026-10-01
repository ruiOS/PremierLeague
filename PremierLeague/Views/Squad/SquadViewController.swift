//
//  SquadViewController.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import UIKit

// MARK: - Squad View Controller
final class SquadViewController: UIViewController {

    // MARK: Dependencies
    private let viewModel: SquadViewModelable

    // MARK: UI
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search players…"
        return sc
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .systemGroupedBackground
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 76
        tv.sectionHeaderHeight = UITableView.automaticDimension
        tv.estimatedSectionHeaderHeight = 40
        tv.dataSource = self
        tv.delegate = self
        tv.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseIdentifier)
        tv.register(PositionHeaderView.self, forHeaderFooterViewReuseIdentifier: PositionHeaderView.reuseIdentifier)
        return tv
    }()

    private lazy var emptySearchLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "No players match your search."
        l.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()

    private var searchDebounceWorkItem: DispatchWorkItem?

    // MARK: Init
    init(viewModel: SquadViewModelable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupLayout()
        bindViewModel()
        render()
    }

    // MARK: Setup
    private func setupNavigationBar() {
        title = viewModel.teamName
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupLayout() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        view.addSubview(emptySearchLabel)

        let emptySearchPadding: CGFloat = 32
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptySearchLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptySearchLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptySearchLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: emptySearchPadding),
            emptySearchLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -emptySearchPadding),
        ])
    }

    private func bindViewModel() {
        viewModel.sectionsDidChange = { [weak self] in
            self?.handleSectionsChange()
        }
    }
}

// MARK: MainActor UI Updates
@MainActor
private extension SquadViewController {

    func handleSectionsChange() {
        render()
    }

    func render() {
        let isEmpty = viewModel.contentState.isEmpty
        emptySearchLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        UIView.transition(
            with: tableView,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.tableView.reloadData()
            }
        )
    }
}

// MARK: UITableViewDataSource
extension SquadViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfPlayers(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PlayerCell.reuseIdentifier,
            for: indexPath
        ) as? PlayerCell else {
            return UITableViewCell()
        }
        let player = viewModel.player(at: indexPath)
        cell.configure(with: player, positionShortName: player.elementType.shortName)
        return cell
    }
}

// MARK: UITableViewDelegate
extension SquadViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: PositionHeaderView.reuseIdentifier
        ) as? PositionHeaderView else {
            return nil
        }
        header.configure(
            title: viewModel.sectionTitle(for: section),
            count: viewModel.sectionPlayerCount(for: section)
        )
        return header
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        8
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
}

// MARK: UISearchResultsUpdating
extension SquadViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        searchDebounceWorkItem?.cancel()

        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            viewModel.updateSearch(query: "")
            return
        }

        let workItem = DispatchWorkItem { [weak self] in
            self?.viewModel.updateSearch(query: query)
        }
        searchDebounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem)
    }
}
