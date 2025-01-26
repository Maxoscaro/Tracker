//
//  StatisticsViewController.swift
//  TrackerApp
//
//  Created by Maksim on 04.10.2024.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "WhiteYP")
        setupLabel()
    }
    
    private func setupLabel() {
        let label = UILabel()
        label.text = "Statistics View Controller"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
//Api Key 84e36de0-9bf9-4082-a43b-e35cd4cd3293
