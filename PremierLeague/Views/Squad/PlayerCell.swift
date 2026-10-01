//
//  PlayerCell.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import UIKit

// MARK: - Player Cell
final class PlayerCell: UITableViewCell {

    static let reuseIdentifier = "PlayerCell"

    // MARK: UI Components
    private let statusDot: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 5
        return v
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.preferredFont(forTextStyle: .headline)
        l.adjustsFontForContentSizeCategory = true
        l.numberOfLines = 0
        l.textColor = .label
        return l
    }()

    private let positionBadge: PillLabel = {
        let p = PillLabel()
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()

    private let priceLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.preferredFont(forTextStyle: .subheadline)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .secondaryLabel
        return l
    }()

    private let pointsLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        let baseFont = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        l.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: baseFont)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .label
        l.textAlignment = .right
        return l
    }()

    private let pointsCaptionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.preferredFont(forTextStyle: .caption2)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .tertiaryLabel
        l.text = "pts"
        l.textAlignment = .right
        return l
    }()

    private let pointsStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .trailing
        sv.spacing = 0
        return sv
    }()

    private let nameStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 4
        return sv
    }()

    private let subtitleStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        return sv
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 12
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 4
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        return v
    }()

    // MARK: Initialiser
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.shadowPath = UIBezierPath(
            roundedRect: containerView.bounds,
            cornerRadius: containerView.layer.cornerRadius
        ).cgPath
    }

    // MARK: Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear

        subtitleStack.addArrangedSubview(statusDot)
        subtitleStack.addArrangedSubview(positionBadge)
        subtitleStack.addArrangedSubview(priceLabel)

        nameStack.addArrangedSubview(nameLabel)
        nameStack.addArrangedSubview(subtitleStack)

        pointsStack.addArrangedSubview(pointsLabel)
        pointsStack.addArrangedSubview(pointsCaptionLabel)

        containerView.addSubview(nameStack)
        containerView.addSubview(pointsStack)

        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),

            nameStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            nameStack.trailingAnchor.constraint(equalTo: pointsStack.leadingAnchor, constant: -8),
            nameStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            pointsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            pointsStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            pointsStack.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 8),
            pointsStack.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8),
            pointsStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),

            statusDot.widthAnchor.constraint(equalToConstant: 10),
            statusDot.heightAnchor.constraint(equalToConstant: 10),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 72),
        ])
    }

    // MARK: Configuration
    func configure(with player: FPLPlayer, positionShortName: String) {
        nameLabel.text = player.webName
        priceLabel.text = player.formattedPrice
        positionBadge.configure(text: positionShortName, position: player.elementType)
        pointsLabel.text = "\(player.totalPoints)"

        statusDot.backgroundColor = player.status.statusDotColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        priceLabel.text = nil
        pointsLabel.text = nil
        statusDot.backgroundColor = .clear
        positionBadge.configure(text: "", position: nil)
    }
}

// MARK: Pill Label
final class PillLabel: UIView {

    private let label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        let baseFont = UIFont.systemFont(ofSize: 10, weight: .bold)
        l.font = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: baseFont)
        l.adjustsFontForContentSizeCategory = true
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 4
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(text: String, position: PlayerPosition?) {
        label.text = text
        if let position = position {
            backgroundColor = position.badgeBackgroundColor
            label.textColor = position.badgeTextColor
        } else {
            backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
            label.textColor = .secondaryLabel
        }
    }
}
