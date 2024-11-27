//
//  ColorDelegate.swift
//  TrackerApp
//
//  Created by Maksim on 03.11.2024.
//

import UIKit

final class ColorCollectionViewDelegate: NSObject, UICollectionViewDataSource,
                                         UICollectionViewDelegate,
                                         UICollectionViewDelegateFlowLayout {
    // MARK: - Types
    
    private enum Constants {
        static let itemsPerRow: CGFloat = 6
        static let sectionInsets = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 19)
        static let interItemSpacing: CGFloat = 5
    }
    
    // MARK: - Properties
    
    weak var createTrackerVC: CreateTrackerViewController?
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let colorCount = createTrackerVC?.getColors().count else { return 0 }
        return colorCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        guard let color = createTrackerVC?.getColors()[indexPath.item] else { return cell }
        cell.configure(with: color, setSelected: indexPath == createTrackerVC?.getSelectedColorsIndex())
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ColorHeader", for: indexPath) as? ColorHeader else {
            return ColorHeader()
        }
        header.label.text = "Цвет"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        createTrackerVC?.setSelectedColorIndex(indexPath)
        collectionView.reloadData()
        
    }
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let screenWidth = createTrackerVC?.view.frame.width else { return CGSize() }
        let paddingSpace = Constants.sectionInsets.left + Constants.sectionInsets.right + Constants.interItemSpacing * (Constants.itemsPerRow - 1)
        let availableWidth = screenWidth - paddingSpace
        let widthPerItem = availableWidth / Constants.itemsPerRow
        let heightPerItem = widthPerItem
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Constants.sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


