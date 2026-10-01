//
//  TeamCell.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import UIKit

// MARK: - Team Cell
final class TeamCell: UITableViewCell {

    static let reuseIdentifier = "TeamCell"

    // MARK: UI Components

    private let badgeContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        return v
    }()

    private let shortNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        let baseFont = UIFont.systemFont(ofSize: 13, weight: .black)
        l.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: baseFont)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .white
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        return l
    }()

    private let teamNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.preferredFont(forTextStyle: .headline)
        l.adjustsFontForContentSizeCategory = true
        l.numberOfLines = 0
        l.textColor = .label
        return l
    }()

    private let playerCountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.preferredFont(forTextStyle: .subheadline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .secondaryLabel
        return l
    }()

    private let labelsStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 3
        return sv
    }()

    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    // MARK: Layout
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear

        badgeContainer.addSubview(shortNameLabel)
        labelsStack.addArrangedSubview(teamNameLabel)
        labelsStack.addArrangedSubview(playerCountLabel)

        contentView.addSubview(badgeContainer)
        contentView.addSubview(labelsStack)

        NSLayoutConstraint.activate([
            badgeContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            badgeContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            badgeContainer.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 12),
            badgeContainer.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            badgeContainer.widthAnchor.constraint(equalToConstant: 52),
            badgeContainer.heightAnchor.constraint(equalToConstant: 52),

            shortNameLabel.centerXAnchor.constraint(equalTo: badgeContainer.centerXAnchor),
            shortNameLabel.centerYAnchor.constraint(equalTo: badgeContainer.centerYAnchor),
            shortNameLabel.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor, constant: 4),
            shortNameLabel.trailingAnchor.constraint(equalTo: badgeContainer.trailingAnchor, constant: -4),

            labelsStack.leadingAnchor.constraint(equalTo: badgeContainer.trailingAnchor, constant: 14),
            labelsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelsStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            labelsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 76)
        ])
    }

    func configure(with team: FPLTeam) {
        shortNameLabel.text = team.shortName
        teamNameLabel.text = team.name
        playerCountLabel.text = "\(team.computedPlayerCount) players"

        let colors = AppTheme.Team.color(for: team.id)
        badgeContainer.backgroundColor = colors.background
        shortNameLabel.textColor = colors.text
    }

    // MARK: Highlight
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.contentView.alpha = highlighted ? 0.6 : 1.0
            self.contentView.transform = highlighted
                ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
}
