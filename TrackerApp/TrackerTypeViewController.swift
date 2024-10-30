//
//  TrackerTypeViewController.swift
//  TrackerApp
//
//  Created by Maksim on 08.10.2024.
//

import UIKit

final class TrackerTypeViewController: UIViewController {
    
    // MARK: - Dependencies
       
       weak var trackersVC: TrackersViewController?
       var onTypeSelected: ((TrackerType) -> Void)?
       
       // MARK: - Private Properties
       
       private let createNewHabitVC = CreateTrackerViewController(type: .habit)
       private let createNotRegularEvent = CreateTrackerViewController(type: .notRegularEvent)
       
       // MARK: - UI Elements
       
       private var screenTitle: UILabel?
       private var habitButton: UIButton?
       private var eventButton: UIButton?
       
       // MARK: - Lifecycle
       
       override func viewDidLoad() {
           super.viewDidLoad()
           setupAppearance()
           setupUI()
       }
       
       // MARK: - Setup Methods
       
       private func setupAppearance() {
           view.backgroundColor = .white
       }
       
       private func setupUI() {
           setupScreenTitle()
           setupEventButton()
           setupHabitButton()
           setupStackView()
       }
       
       private func setupScreenTitle() {
           let label = UILabel()
           label.text = "Создание трекера"
           label.font = UIFont.systemFont(ofSize: 16)
           label.textColor = .black
           label.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(label)
           
           NSLayoutConstraint.activate([
               label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
               label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22)
           ])
           
           self.screenTitle = label
       }
       
       private func setupButton(with text: String) -> UIButton {
           let button = UIButton(type: .system)
           button.setTitle(text, for: .normal)
           button.setTitleColor(.white, for: .normal)
           button.backgroundColor = .black
           button.layer.cornerRadius = 16
           return button
       }
       
       private func setupHabitButton() {
           let habitButton = setupButton(with: "Привычка")
           habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
           self.habitButton = habitButton
       }
       
       private func setupEventButton() {
           let eventButton = setupButton(with: "Нерегулярное событие")
           eventButton.addTarget(self, action: #selector(eventButtonTapped), for: .touchUpInside)
           self.eventButton = eventButton
       }
       
       private func setupStackView() {
           guard let habitButton = habitButton, let eventButton = eventButton else { return }
           
           let stackView = UIStackView(arrangedSubviews: [habitButton, eventButton])
           stackView.axis = .vertical
           stackView.alignment = .fill
           stackView.distribution = .fill
           stackView.spacing = 16
           stackView.translatesAutoresizingMaskIntoConstraints = false
           
           view.addSubview(stackView)
           
           NSLayoutConstraint.activate([
               stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
               stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
               stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
               stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               
               habitButton.heightAnchor.constraint(equalToConstant: 60),
               eventButton.heightAnchor.constraint(equalToConstant: 60)
           ])
       }
       
       // MARK: - Actions
       
       @objc private func habitButtonTapped() {
           createNewHabitVC.onTrackerCreated = { [weak self] tracker, categoryTitle in
               self?.trackersVC?.addTracker(tracker, toCategory: categoryTitle)
           }
           
           present(createNewHabitVC, animated: true)
       }
       
       @objc private func eventButtonTapped() {
           createNotRegularEvent.onTrackerCreated = { [weak self] tracker, categoryTitle in
               self?.trackersVC?.addTracker(tracker, toCategory: categoryTitle)
           }
           
           present(createNotRegularEvent, animated: true)
       }
   }
