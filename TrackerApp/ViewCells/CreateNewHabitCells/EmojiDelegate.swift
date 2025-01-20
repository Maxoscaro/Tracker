//
//  EmojiDelegate.swift
//  TrackerApp
//
//  Created by Maksim on 01.11.2024.
//

import UIKit

final class EmojiCollectionViewDelegate: NSObject, UICollectionViewDataSource,
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
        guard let emojiCount = createTrackerVC?.getEmojies().count else { return 0 }
        return emojiCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        guard let emoji = createTrackerVC?.getEmojies()[indexPath.item] else { return cell }
        cell.configure(emoji: emoji)
        cell.setSelected(indexPath == createTrackerVC?.getSelectedEmojiIndex())
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "EmojiHeader", for: indexPath) as? EmojiHeader else {
            return EmojiHeader()
        }
        header.label.text = "Emoji"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        createTrackerVC?.setSelectedEmojiIndex(indexPath)
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

