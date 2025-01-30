//
//  OnboardingScreenViewController.swift
//  TrackerApp
//
//  Created by Maksim on 18.01.2025.
//

import UIKit

final class OnboardingScreenViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let backGroundImageString: String?
    private let titleText: String?
    
    // MARK: - UI Elements
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "BlackYP")
        if let font = UIFont(name: "SFProText-Bold", size: 32) {
            label.font = font
        } else {
            label.font = .systemFont(ofSize: 32, weight: .bold)
            print("Failed to load SF Pro Display Bold font")
        }
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    init(backGroundImageString: String, titleText: String) {
        self.backGroundImageString = backGroundImageString
        self.titleText = titleText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
}

// MARK: - UIViewConfigurableProtocol

extension OnboardingScreenViewController: UIViewConfigurableProtocol {
    func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(textLabel)
        
        if let imageName = backGroundImageString {
            backgroundImageView.image = UIImage(named: imageName)
        }
        textLabel.text = titleText
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            textLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 60),
            textLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
            
        ])
    }
}
