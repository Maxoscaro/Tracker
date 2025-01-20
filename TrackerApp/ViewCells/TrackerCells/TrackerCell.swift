//
//  TrackerCell.swift
//  TrackerApp
//
//  Created by Maksim on 19.10.2024.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    weak var trackersVC: TrackersViewController?
    private var tracker: Tracker?
    private var selectedDate: Date?
    
    private var isTrackerComplete = false
    private var durationCountInt = 0
    private var cellColor: UIColor = .systemGreen
    
    // MARK: - UI Elements
    
    private let cardView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return label
    }()
    
    private let cardText: UILabel = {
        let text = UILabel()
        text.font = UIFont.systemFont(ofSize: 12)
        text.textColor = .white
        text.translatesAutoresizingMaskIntoConstraints = false
        text.numberOfLines = 0
        return text
    }()
    
    private let countDaysLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "BlackYP")
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(named: "WhiteYP")
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.imageView?.frame.size = CGSize(width: 8, height: 8)
        button.backgroundColor = .green
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        button.addTarget(TrackerCell.self, action: #selector(plusButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Public Methods
    
    func configure(with tracker: Tracker, on date: Date) {
        self.tracker = tracker
        selectedDate = date
        
        cardText.text = tracker.title
        emojiLabel.text = tracker.emoji
        cardView.backgroundColor = UIColor(hexString: tracker.color)
        cellColor = UIColor(hexString: tracker.color) ?? .green
        self.isTrackerComplete = trackersVC?.isTrackerCompleted(tracker, on: date) ?? false
        
        updateUI(with: cellColor)
        countDaysLabel.text = "\(durationCountInt) \(convertDays(durationCountInt))"
    }
    
    // MARK: - Private Methods
    
    private func updateUI(with color: UIColor) {
        cardView.backgroundColor = color
        
        if isTrackerComplete {
            plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            plusButton.backgroundColor = color.withAlphaComponent(0.5)
        } else {
            plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
            plusButton.backgroundColor = color.withAlphaComponent(1)
        }
    }
    
    private func encreaseDurationLabel() {
        durationCountInt += 1
        countDaysLabel.text = "\(durationCountInt) \(convertDays(durationCountInt))"
        guard let tracker = self.tracker, let selectedDate = selectedDate else { return }
        trackersVC?.setTrackerComplete(for: tracker, on: selectedDate)
    }
    
    private func decreaseDurationLabel() {
        durationCountInt -= 1
        countDaysLabel.text = "\(durationCountInt) \(convertDays(durationCountInt))"
        guard let tracker = self.tracker, let selectedDate = selectedDate else { return }
        trackersVC?.setTrackerIncomplete(for: tracker, on: selectedDate)
    }
    
    private func convertDays(_ count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "дней"
        }
        
        switch lastDigit {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }
    
    // MARK: - Actions
    
    @objc private func plusButtonTapped() {
        isTrackerComplete = !isTrackerComplete
        guard let selectedDate = trackersVC?.getDateFromUIDatePicker() else { return }
        let currentDate = Date()
        
        if selectedDate > currentDate {
            return
        } else {
            if let tracker = self.tracker {
                updateUI(with: cellColor)
            }
            
            if isTrackerComplete {
                encreaseDurationLabel()
            } else {
                decreaseDurationLabel()
            }
        }
    }
}

// MARK: - UIViewConfigurableProtocol

extension TrackerCell: UIViewConfigurableProtocol {
    func setupUI() {
        contentView.addSubview(cardView)
        contentView.addSubview(countDaysLabel)
        contentView.addSubview(plusButton)
        
        cardView.addSubview(emojiLabel)
        cardView.addSubview(cardText)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            cardText.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            cardText.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            cardText.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            cardText.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            countDaysLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            countDaysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countDaysLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            plusButton.centerYAnchor.constraint(equalTo: countDaysLabel.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}
