//
//  TabBarController.swift
//  TrackerApp
//
//  Created by Maksim on 04.10.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    private let trackersTabBarTitle = "Трекеры"
    private let statisticsTabBarTitle = "Статистика"
    private let tapBarHight: CGFloat = 90.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupTabBarView()
    }
    
    private func setupViewControllers() {
        let trackerStore = TrackerStore.shared
            let trackersViewController = TrackersViewController(trackerStore: trackerStore)
        let statisticsViewController = StatisticsViewController()
        
        trackersViewController.tabBarItem = UITabBarItem(title: trackersTabBarTitle, image: UIImage(named: "PropertyTrackers"), tag: 0)
        statisticsViewController.tabBarItem = UITabBarItem(title: statisticsTabBarTitle, image: UIImage(named: "PropertyStats"), tag: 1)
        
        let navigationController = UINavigationController(rootViewController: trackersViewController)
        
        viewControllers = [ navigationController, statisticsViewController ]
    }
    
    private func setupTabBarView() {
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
        tabBar.addTopBorder(with: UIColor(named: "BlackTB") ?? .gray, andHeight: 1)
    }
}

extension UITabBar {
    func addTopBorder(with color: UIColor, andHeight borderHeight: CGFloat) {
        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: borderHeight)
        borderLayer.backgroundColor = color.cgColor
        self.layer.addSublayer(borderLayer)
    }
}
