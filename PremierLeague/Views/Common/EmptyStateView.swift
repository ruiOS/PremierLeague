//
//  EmptyStateView.swift
//  PremierLeague
//
//  Created by Lurdhu Rupesh Kumar Pudota on 30/09/26.
//

import UIKit

// MARK: - Empty State View
final class EmptyStateView: UIView {

    // MARK: Callback
    var onRetry: (() -> Void)?

    // MARK: UI
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .tertiaryLabel
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        l.textColor = .tertiaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Try Again"
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor(red: 0.24, green: 0.0, blue: 0.54, alpha: 1)
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 12
        return sv
    }()

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    // MARK: Setup
    private func setupUI() {
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(retryButton)
        stackView.setCustomSpacing(20, after: iconImageView)
        stackView.setCustomSpacing(20, after: messageLabel)
        addSubview(stackView)

        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        let iconImageSize: CGFloat = 72
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: iconImageSize),
            iconImageView.heightAnchor.constraint(equalToConstant: iconImageSize),
        ])
    }

    // MARK: Configuration
    func configure(icon: String, title: String, message: String, showRetry: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 52, weight: .light)
        iconImageView.image = UIImage(systemName: icon, withConfiguration: config)
        titleLabel.text = title
        messageLabel.text = message
        retryButton.isHidden = !showRetry
    }

    // MARK: Actions
    @objc private func retryTapped() {
        onRetry?()
    }
}
