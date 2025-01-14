//
//  ChooseCategoryViewController.swift
//  TrackerApp
//
//  Created by Maksim on 16.10.2024.
//

import UIKit

final class ChooseCategoryViewController: UIViewController {
    
    // MARK: - Dependencies
    
    weak var trackersVC: TrackersViewController?
    weak var delegate: CreateTrackerViewController?
    
    // MARK: - UI Elements
    
    private lazy var screenTitle: UILabel = {
        let title = UILabel()
        title.text = "Категория"
        title.textColor = UIColor(named: "BlackYP")
        title.font = .systemFont(ofSize: 16)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var addNewCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.backgroundColor = UIColor(named: "BlackYP")
        button.layer.cornerRadius = 16
        button.setTitleColor(UIColor(named: "WhiteYP"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "WhiteYP")
        setupUI()
        setupConstraints()
    }
}

    // MARK: - ConfigurableProtocol
        
extension ChooseCategoryViewController: UIViewConfigurableProtocol {
    
    func setupUI() {
        [screenTitle, addNewCategoryButton].forEach { view.addSubview($0) }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            screenTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
            screenTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            addNewCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addNewCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addNewCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addNewCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
