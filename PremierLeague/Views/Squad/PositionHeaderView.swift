//
//  PositionHeaderView.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import UIKit

// MARK: - Position Section Header View
final class PositionHeaderView: UITableViewHeaderFooterView {

    static let reuseIdentifier = "PositionHeaderView"

    // MARK: UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 13, weight: .heavy)
        l.textColor = .secondaryLabel
        return l
    }()

    private let countLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = .tertiaryLabel
        return l
    }()

    private let separator: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .separator
        return v
    }()

    // MARK: - Initialiser

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    // MARK: - Setup

    private func setupUI() {
        contentView.backgroundColor = .systemGroupedBackground

        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(separator)

        let heightConstraint = contentView.heightAnchor.constraint(equalToConstant: 38)
        heightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            countLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            countLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),

            heightConstraint,
        ])
    }

    // MARK: Configuration
    func configure(title: String, count: Int) {
        titleLabel.text = title.uppercased()
        countLabel.text = "(\(count))"
    }
}
