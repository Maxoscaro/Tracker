//
//  StatisticsViewController.swift
//  TrackerApp
//
//  Created by Maksim on 04.10.2024.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - Dependencies
    private let trackerRecordStore = TrackerRecordStore.shared
    private let statisticsStore = StatisticsStore.shared
    private let trackerStore = TrackerStore.shared
    
    // MARK: - Private Properties
    private enum StatisticsMetric {
        case bestPeriod
        case perfectDays
        case completed
        case averageValue
        
        var title: String {
            switch self {
            case .bestPeriod:
                return LocalizedStrings.Statistics.bestPeriod
            case .perfectDays:
                return LocalizedStrings.Statistics.perfectDays
            case .completed:
                return LocalizedStrings.Statistics.trackersCompleted
            case .averageValue:
                return LocalizedStrings.Statistics.trackersCountAvarage
            }
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedStrings.Statistics.title
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "SFProText-Bold", size: 34)
        label.textColor = UIColor(named: "BlackYP")
        return label
    }()
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "emptyStatisticsIcon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizedStrings.Statistics.noDataText
        label.textAlignment = .center
        label.font = UIFont(name: "SFProText-Medium", size: 12)
        label.textColor = UIColor(named: "BlackYP")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func createCounterView(title: String, value: Int) -> StatisticsCounterView {
        let counter = StatisticsCounterView(value: value, title: title)
        counter.translatesAutoresizingMaskIntoConstraints = false
        return counter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatisticsData()
    }
    
    // MARK: - UI Methods
    private func updateStatisticsData() {
        let totalRecords = statisticsStore.fetchAllRecordsCount()
        
         if totalRecords > 0 {
             guard let date = trackerRecordStore.fetchEarliestTrackerRecord()?.date else {
            
                 return
             }
             
             statisticsStore.updateStatistics(with: date, trackerStore: self.trackerStore)
         } else {
           
             statisticsStore.clearStatistics()
         }
        
        updateUI()
    }
    
    private func updateUI() {
        let isEmpty = isStatisticsEmpty()
        placeholderView.isHidden = !isEmpty
        statsStackView.isHidden = isEmpty
        
        guard !isEmpty else { return }
        
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        [
            (StatisticsMetric.bestPeriod.title, statisticsStore.bestPeriodCount),
            (StatisticsMetric.perfectDays.title, statisticsStore.perfectDaysCount),
            (StatisticsMetric.completed.title, statisticsStore.trackersCompleteCount),
            (StatisticsMetric.averageValue.title, statisticsStore.averageCount)
        ].forEach { title, value in
            let counterView = createCounterView(title: title, value: value)
            statsStackView.addArrangedSubview(counterView)
        }
    }
    
    private func isStatisticsEmpty() -> Bool {
        if statisticsStore.perfectDaysCount == 0,
           statisticsStore.trackersCompleteCount == 0,
           statisticsStore.averageCount == 0,
           statisticsStore.bestPeriodCount == 0 {
            return true
        } else {
            return false
        }
    }
}

extension StatisticsViewController: UIViewConfigurableProtocol {
    func setupUI() {
        view.backgroundColor = UIColor(named: "WhiteYP")
        view.addSubview(titleLabel)
        view.addSubview(placeholderView)
        view.addSubview(statsStackView)
        
        placeholderView.addSubview(placeholderImageView)
        placeholderView.addSubview(placeholderLabel)
        
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 44),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),
            
            statsStackView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: 77),
            statsStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16),
            
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            placeholderImageView.topAnchor.constraint(equalTo: placeholderView.topAnchor),
            placeholderImageView.widthAnchor.constraint(
                equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(
                equalToConstant:80),
            
            placeholderLabel.topAnchor.constraint(
                equalTo: placeholderImageView.bottomAnchor,
                constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: placeholderView.bottomAnchor),
        ])
    }
}




