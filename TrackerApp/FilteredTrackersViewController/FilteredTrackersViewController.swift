//
//  FilteredTrackersViewController.swift
//  TrackerApp
//
//  Created by Maksim on 27.01.2025.
//

import UIKit

final class FilteredTrackersViewController: UIViewController {
    
    private var selectedIndexPath: IndexPath?
    var delegate: TrackersViewController?
    
    private let filters = [
        NSLocalizedString("FilterTrackersScreen_AllTrackers", comment: "Все трекеры"),
        NSLocalizedString("FilterTrackersScreen_TodayTrackers", comment: "Трекеры на сегодня"),
        NSLocalizedString("FilterTrackersScreen_CompletedTrackers", comment: "Завершенные"),
        NSLocalizedString("FilterTrackersScreen_UncompletedTrackers", comment: "Не завершенные")
    ]
    
    private lazy var filterTitle: UILabel = {
        let label = UILabel()
        label.text = LocalizedStrings.Trackers.filters
        label.font = UIFont(name: "SFProText-Medium", size: 16)
        label.textColor = UIColor(named: "BlackYP")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor(named: "BlackYP")
        tableView.layer.cornerRadius = 16
        tableView.register(
            FilteredTrackersCell.self, forCellReuseIdentifier:  FilteredTrackersCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        tableView.reloadData()
    }
    
    func setFilter(_ filter: FilterType) {
        FilterStore.selectedFilter = filter
        updateTableView()
    }
    
    private func updateTableView() {
        switch FilterStore.selectedFilter {
        case .allTrackers:
            selectedIndexPath = IndexPath(row: 0, section: 0)
        case .todayTrackers:
            selectedIndexPath = IndexPath(row: 1, section: 0)
        case .completedTrackers:
            selectedIndexPath = IndexPath(row: 2, section: 0)
        case .uncompletedTrackers:
            selectedIndexPath = IndexPath(row: 3, section: 0)
        }
        
        tableView.reloadData()
    }
}

extension FilteredTrackersViewController: UIViewConfigurableProtocol {
    func setupUI() {
        view.backgroundColor = UIColor(named: "WhiteYP")
        [filterTitle, tableView].forEach { view.addSubview($0) }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            filterTitle.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            filterTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(
                equalTo: filterTitle.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension FilteredTrackersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilteredTrackersCell.identifier, for: indexPath) as? FilteredTrackersCell else {
            return UITableViewCell ()
        }
        
        let filterTitle = filters[indexPath.row]
           cell.backgroundColor = UIColor(named: "Background")
           cell.configure(with: filterTitle, isSelected: indexPath == selectedIndexPath)

           if indexPath.row == 0 {
               cell.layer.cornerRadius = 16
               cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
               cell.layer.masksToBounds = true
           } else if indexPath.row == filters.count - 1 {
               cell.layer.cornerRadius = 16
               cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
               cell.layer.masksToBounds = true
               cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
           } else {
               cell.layer.cornerRadius = 0
               cell.layer.masksToBounds = true
           }
           
           return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == filters.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousIndexPath = selectedIndexPath
        selectedIndexPath = indexPath
        
        let filterType: FilterType
        switch indexPath.row {
        case 0:
            filterType = .allTrackers
        case 1:
            filterType = .todayTrackers
        case 2:
            filterType = .completedTrackers
        case 3:
            filterType = .uncompletedTrackers
        default:
            return
        }
        
        FilterStore.selectedFilter = filterType
        delegate?.handleFilterSelection(filterType)
        
        var indexPathsToReload: [IndexPath] = [indexPath]
        if let previousIndexPath = previousIndexPath {
            indexPathsToReload.append(previousIndexPath)
        }
        
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
