//
//  StatisticsCounterView.swift
//  TrackerApp
//
//  Created by Maksim on 28.01.2025.
//

import UIKit

final class StatisticsCounterView: UIView {

    // MARK: - UI Components
       private let stackView: UIStackView = {
           let stack = UIStackView()
           stack.axis = .vertical
           stack.spacing = 7
           stack.translatesAutoresizingMaskIntoConstraints = false
           return stack
       }()
       
       private let valueLabel: UILabel = {
           let label = UILabel()
           label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
           label.textColor = UIColor(named: "BlackYP")
           return label
       }()
       
       private let titleLabel: UILabel = {
           let label = UILabel()
           label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
           label.textColor = UIColor(named: "BlackYP")
           label.numberOfLines = 0
           return label
       }()
       
       private let gradientBorder = CAGradientLayer()
       
       // MARK: - Initialization
       init(value: Int, title: String) {
           super.init(frame: .zero)
           setupView()
           configure(value: value, title: title)
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
       
       // MARK: - Public Methods
       func update(value: Int, title: String) {
           configure(value: value, title: title)
       }
       
       // MARK: - Private Methods
       private func configure(value: Int, title: String) {
           valueLabel.text = "\(value)"
           titleLabel.text = title
       }
       
       private func setupView() {
           backgroundColor = UIColor(named: "WhiteYP")
           layer.cornerRadius = 16
           setupGradientBorder()
           setupLayout()
       }
       
       private func setupGradientBorder() {
           gradientBorder.colors = [
            UIColor.red.cgColor,
            UIColor.green.cgColor,
            UIColor.blue.cgColor
           ]
           gradientBorder.startPoint = CGPoint(x: 0, y: 0.5)
           gradientBorder.endPoint = CGPoint(x: 1, y: 0.5)
           layer.addSublayer(gradientBorder)
       }
       
       private func setupLayout() {
           addSubview(stackView)
           [valueLabel, titleLabel].forEach { stackView.addArrangedSubview($0) }
           
           NSLayoutConstraint.activate([
               stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
               stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
               stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
               stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
           ])
       }
       
       override func layoutSubviews() {
           super.layoutSubviews()
           gradientBorder.frame = bounds
           let path = UIBezierPath(roundedRect: bounds, cornerRadius: 16)
           let shape = CAShapeLayer()
           shape.path = path.cgPath
           shape.lineWidth = 1
           shape.strokeColor = UIColor.black.cgColor
           shape.fillColor = UIColor.clear.cgColor
           gradientBorder.mask = shape
       }
   }
