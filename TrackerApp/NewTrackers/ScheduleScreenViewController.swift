//
//  ScheduleScreenViewController.swift
//  TrackerApp
//
//  Created by Maksim on 17.10.2024.
//

import UIKit

final class ScheduleScreenViewController: UIViewController {
    
    // MARK: - Dependencies
    
    weak var delegate: CreateTrackerViewController?
    
    // MARK: - Private Properties
    
    private let weekDays = WeekDay.allCases
    private var selectedWeekDays: Set<WeekDay> = []
    private var switchStatus = [Bool](repeating: false, count: 7)
    
    // MARK: - UI Elements
    
    private lazy var screenTitle: UILabel = {
        let title = UILabel()
        title.text = "Расписание"
        title.textColor = UIColor(named: "BlackYP")
        title.font = .systemFont(ofSize: 16)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = UIColor(named: "BlackYP")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.clipsToBounds = true
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = UIColor(named: "BlackYP")
        button.layer.cornerRadius = 16
        button.setTitleColor(UIColor(named: "WhiteYP"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Public Methods
    
    func resetSchedule() {
        selectedWeekDays.removeAll()
        switchStatus = [Bool](repeating: false, count: 7)
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    
    private func setupAppearance() {
        view.backgroundColor = UIColor(named: "WhiteYP")
    }
    
    private func setupUI() {
        [screenTitle, tableView, doneButton].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            screenTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
            screenTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: screenTitle.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 20),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        delegate?.updateSelectedWeekdays(selectedWeekDays)
        dismiss(animated: true)
    }
    
    @objc private func switchStatusChanged(_ sender: UISwitch) {
        let weekDay = weekDays[sender.tag]
        
        if sender.isOn {
            selectedWeekDays.insert(weekDay)
        } else {
            selectedWeekDays.remove(weekDay)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ScheduleScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let weekDay = weekDays[indexPath.row]
        
        configureCell(cell, with: weekDay, at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    private func configureCell(_ cell: UITableViewCell, with weekDay: WeekDay, at indexPath: IndexPath) {
        cell.textLabel?.text = weekDay.rawValue
        cell.backgroundColor = UIColor(named: "Background")
        
        let switchView = UISwitch(frame: .zero)
        switchView.tag = indexPath.row
        switchView.onTintColor = UIColor.systemBlue
        switchView.setOn(switchStatus[indexPath.row], animated: true)
        switchView.addTarget(self, action: #selector(switchStatusChanged), for: .valueChanged)
        cell.accessoryView = switchView
        
        if indexPath.row == weekDays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        if indexPath.row == 0 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.cornerRadius = 16
            cell.clipsToBounds = true
        } else if indexPath.row == weekDays.count - 1 {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.cornerRadius = 16
            cell.clipsToBounds = true
        } else {
            cell.layer.cornerRadius = 0 
        }
    }
}
